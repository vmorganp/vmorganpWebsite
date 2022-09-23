---
title: 'Website'
date: 2022-09-21T00:42:57-07:00
tags: ['project']
---

My personal website

[Repository](https://github.com/vmorganp/vmorganpWebsite)

[Inception](https://vmorganp.com)

## How
Using technologies including: 
- Terraform (Infrastructure as Code)
- AWS (hosting)
- HUGO (static site generator)
- Github actions (Automated build/deploy)


## Build log
1. 22 Sept 2022 - The first entry in this build log is way down the development line. I didn't start this log until long after I'd started building the site. The infrastrucure as code for this was painful. Working with S3 and cloudfront seems like it should have first class support, but there is definitely some custom or at least not "out-of-box" pieces of the IAC that took far too long to flesh out. One such example is: 
```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_id   = local.origin_id
    domain_name = aws_s3_bucket.host_bucket.website_endpoint
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
```

After working out this domain/custom origin stuff, it works (well hopefully, assuming you're reading this.
On a less painful note, HUGO is an absolute pleasure to work with. It's super easy to most basic things, though the way different themes handle different types of pages was not quite intuitive to me. 
