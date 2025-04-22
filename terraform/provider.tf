# Default provider for S3 and most operations
provider "aws" {
  region = "us-east-1"
}

# Provider alias for resources that specifically need us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}