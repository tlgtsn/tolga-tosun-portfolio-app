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
  for_each = toset(var.domains)
  bucket   = aws_s3_bucket.site[each.key].bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"  # This ensures that all routes in your SPA are properly handled
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

    # Allow all HTTP methods if needed
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    
    # Forward headers and cookies if your app needs them
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }

    # Optimize caching for SPA
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour for default caching
    max_ttl                = 86400 # 24 hours max
  }
  
  aliases = each.key == "tolgatosun.dev" ? ["www.tolgatosun.dev"] : ["staging.tolgatosun.dev"]

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

  # Custom error responses - these are necessary for SPA routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/404.html"
  }

  tags = { Environment = each.key == "tolgatosun.dev" ? "prod" : "staging" }

  depends_on = [aws_acm_certificate_validation.site]
}

# 4) ACM Certificate
resource "aws_acm_certificate" "site" {
  domain_name       = "tolgatosun.dev"
  validation_method = "DNS"
  provider          = aws.us-east-1

  # Ensuring all domains are covered: tolgatosun.dev, www.tolgatosun.dev, and staging.tolgatosun.dev
  subject_alternative_names = ["www.tolgatosun.dev", "staging.tolgatosun.dev"]

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

# Add Root Domain Redirect Resources
# 1. S3 bucket for root domain
resource "aws_s3_bucket" "root_redirect" {
  bucket = "tolgatosun.dev"
}

# 2. Configure website redirect
resource "aws_s3_bucket_website_configuration" "root_redirect" {
  bucket = aws_s3_bucket.root_redirect.id
  
  redirect_all_requests_to {
    host_name = "www.tolgatosun.dev"
    protocol  = "https"
  }
}

# 3. Make bucket public for website access
resource "aws_s3_bucket_public_access_block" "root_redirect" {
  bucket = aws_s3_bucket.root_redirect.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Add bucket policy that allows public read
resource "aws_s3_bucket_policy" "root_redirect" {
  bucket = aws_s3_bucket.root_redirect.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "s3:GetObject"
      Effect    = "Allow"
      Resource  = "${aws_s3_bucket.root_redirect.arn}/*"
      Principal = "*"
    }]
  })
}

# 5. CloudFront distribution for root domain
resource "aws_cloudfront_distribution" "root_redirect" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Root domain redirect to www"
  price_class         = "PriceClass_100" # Use cheapest option since it's just for redirect
  
  # Origin configuration for S3 website
  origin {
    domain_name = "${aws_s3_bucket.root_redirect.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "S3-Website-Redirect"
    
    # Required for S3 website origins
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  # S3 websites only support HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = "S3-Website-Redirect"
    viewer_protocol_policy = "redirect-to-https"  # Force HTTPS

    # Basic settings
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    
    # Cache settings - short TTL since it's just a redirect
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour
    max_ttl                = 86400 # 24 hours
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  
  # Custom domain
  aliases = ["tolgatosun.dev"]

  # SSL certificate
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  # Dependencies
  depends_on = [aws_acm_certificate_validation.site]
}

# Get current region for S3 website endpoint
data "aws_region" "current" {}