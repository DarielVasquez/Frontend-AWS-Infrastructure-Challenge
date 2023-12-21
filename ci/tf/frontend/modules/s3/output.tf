output "s3_frontend" {
    value = aws_s3_bucket_website_configuration.s3_config.website_endpoint
}