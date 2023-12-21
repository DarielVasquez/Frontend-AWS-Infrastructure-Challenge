resource "aws_cloudfront_distribution" "s3_frontend_distribution" {
  dynamic "origin" {
    for_each = var.s3_frontend
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      custom_origin_config {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }
  
  aliases = tolist(var.hosted_zone_names)
  
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name_prefix} cloudfront distro"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    target_origin_id       = var.s3_frontend[0].origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.s3_frontend
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = ordered_cache_behavior.value.origin_id

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }

      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cloudfront_certificate_arn
    ssl_support_method             = "sni-only"
  }

  depends_on = [ var.s3_frontend ]

  tags = {
    "DevOps"     = var.project_tag
  }
}
