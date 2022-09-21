# bucket to hold all of the website html files
resource "aws_s3_bucket" "host_bucket" {
  bucket = local.site_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
    routing_rules  = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "/"
    },
    "Redirect": {
        "ReplaceKeyWith": "index.html"
    }
}]
EOF
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# policy to allow the buvket to be accessed by cloudfront
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::vmorganp.com/*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

locals {
  mime_types = {
    "html" : "text/html",
    "css" : "text/css",
    "js" : "text/js",
    "xml" : "application/xml",
  }
}

# the files that go into the bucket, these are all webpages
resource "aws_s3_bucket_object" "website" {
  for_each = fileset("../website/hugo/vmorganpWebsite/public", "**")

  bucket       = aws_s3_bucket.host_bucket.id
  key          = each.value
  source       = "../website/hugo/vmorganpWebsite/public/${each.value}"
  etag         = filemd5("../website/hugo/vmorganpWebsite/public/${each.value}")
  source_hash  = "public-read"
  content_type = lookup(local.mime_types, element(split(".", each.value), length(split(".", each.value)) - 1), null)
}
