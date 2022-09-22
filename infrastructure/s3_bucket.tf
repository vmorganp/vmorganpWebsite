# random user agent
resource "random_string" "user_agent" {
  length  = 21
  special = false
}

# bucket to hold all of the website html files
resource "aws_s3_bucket" "host_bucket" {
  bucket = local.site_name
  # acl    = "public-read"
  # policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.host_bucket.bucket
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.host_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "web_config" {
  bucket = aws_s3_bucket.host_bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
  routing_rule {
    condition {
      key_prefix_equals = "/"
    }
    redirect {
      replace_key_prefix_with = "index.html"
    }
  }
}

# policy to allow the buvket to be accessed by cloudfront
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.host_bucket.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"
      values   = [random_string.user_agent.result]
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
  acl          = "public-read"
}
