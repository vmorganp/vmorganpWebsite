provider "aws" {
  region = "us-east-1"
}

# this either needs to be done in us-east-1 or have a separate provider
# for cloudfront because cloudfront only takes ACM certs from us-east-1
terraform {
  backend "s3" {
    bucket         = "thehumangiraffe-statefiles"
    key            = "vmorganpcom/master.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state_lock"
  }
}
