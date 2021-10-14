resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${local.site_name}.s3.amazonaws.com"
}

# make my s3 site run on the cloudfront cdn with valid https
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.host_bucket.bucket_regional_domain_name
    origin_id   = local.origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"
  aliases             = [local.site_name]

  custom_error_response {
    error_caching_min_ttl=0
    error_code=404
    response_code = 404
    response_page_path="/error.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
}

# routing resources
resource "aws_route53_zone" "vmorganpcom" {
  name = local.site_name
}

resource "aws_route53_record" "point_to_cloud_front" {
  zone_id = aws_route53_zone.vmorganpcom.id
  name    = local.site_name
  type    = "A"
  # ttl     = "30"
  # records = [aws_cloudfront_distribution.s3_distribution.domain_name]
  alias {
    name = aws_cloudfront_distribution.s3_distribution.domain_name

    # apparently cloudfront has a static ID for this
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# HTTPS certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = local.site_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.vmorganpcom.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
