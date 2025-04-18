# 1) S3 buckets (one per domain)
resource "aws_s3_bucket" "site" {
  for_each = toset(var.domains)
  bucket   = "tt-${each.key}-${terraform.workspace}"
}

resource "aws_s3_bucket_ownership_controls" "site" {
  for_each = aws_s3_bucket.site
  bucket   = each.value.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  for_each = aws_s3_bucket.site
  bucket   = each.value.id

  # For staging environments, block all public access
  # For production (tolgatosun.dev), allow public access
  block_public_acls       = each.key == "staging.tolgatosun.dev"
  block_public_policy     = each.key == "staging.tolgatosun.dev"
  ignore_public_acls      = each.key == "staging.tolgatosun.dev"
  restrict_public_buckets = each.key == "staging.tolgatosun.dev"
}

resource "aws_s3_bucket_website_configuration" "site" {
  for_each = aws_s3_bucket.site
  bucket   = each.value.id

  index_document {
    suffix = "index.html"
  }
}

# 2) OAI + bucket policy
resource "aws_cloudfront_origin_access_identity" "oai" {
  for_each = toset(var.domains)
  comment  = "OAI for ${each.key}"
}

resource "aws_s3_bucket_policy" "policy" {
  for_each = aws_s3_bucket.site
  bucket   = each.value.id
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = aws_cloudfront_origin_access_identity.oai[each.key].iam_arn }
      Action    = "s3:GetObject"
      Resource  = "${each.value.arn}/*"
    }]
  })
}

# 3) CloudFront distributions
resource "aws_cloudfront_distribution" "dist" {
  for_each = toset(var.domains)
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CF for ${each.key}"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.site[each.key].bucket_regional_domain_name
    origin_id   = "S3-${each.key}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai[each.key].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-${each.key}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET","HEAD"]
    cached_methods         = ["GET","HEAD"]
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = { Environment = each.key == "tolgatosun.dev" ? "prod" : "staging" }

  depends_on = [aws_acm_certificate_validation.site]
}

# 4) ACM Certificate
resource "aws_acm_certificate" "site" {
  domain_name       = "tolgatosun.dev"
  validation_method = "DNS"
  provider         = aws.us-east-1

  subject_alternative_names = ["staging.tolgatosun.dev"]

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_acm_certificate.site.domain_validation_options : record.resource_record_name]
  provider               = aws.us-east-1
}