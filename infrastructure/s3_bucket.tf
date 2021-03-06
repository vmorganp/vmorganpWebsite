# bucket to hold all of the website html files
resource "aws_s3_bucket" "host_bucket" {
  bucket = local.site_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
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

# the files that go into the bucket, these are all webpages
resource "aws_s3_bucket_object" "website" {
  bucket       = aws_s3_bucket.host_bucket.id
  key          = "index.html"
  source       = "../website/index.html"
  etag         = filemd5("../website/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "error_page" {
  bucket       = aws_s3_bucket.host_bucket.id
  key          = "error.html"
  source       = "../website/error.html"
  etag         = filemd5("../website/error.html")
  content_type = "text/html"
}
