output "cloudfront_urls" {
  description = "CloudFront distribution URLs for each domain"
  value = {
    "tolgatosun.dev"          = aws_cloudfront_distribution.dist["tolgatosun.dev"].domain_name
    "tolgatosun.dev_id"       = aws_cloudfront_distribution.dist["tolgatosun.dev"].id
    "staging.tolgatosun.dev"  = aws_cloudfront_distribution.dist["staging.tolgatosun.dev"].domain_name
    "staging.tolgatosun.dev_id" = aws_cloudfront_distribution.dist["staging.tolgatosun.dev"].id
  }
}