# Default provider for S3 and most operations
provider "aws" {
  region = "us-east-1"
}

# Provider specifically for ACM certificates (which must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}