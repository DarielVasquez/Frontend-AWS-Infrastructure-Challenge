output "s3_frontend_distribution" {
  value     = aws_cloudfront_distribution.s3_frontend_distribution
  sensitive = true
}
