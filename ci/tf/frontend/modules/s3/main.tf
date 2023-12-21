resource "aws_s3_bucket" "frontend_s3" {
  bucket = "${var.name_prefix}-frontend-s3"
  force_destroy = true
  tags = {
    "DevOps"     = var.project_tag
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.frontend_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "s3_config" {
  bucket = aws_s3_bucket.frontend_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.frontend_s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.name_prefix}-frontend-s3",
          "arn:aws:s3:::${var.name_prefix}-frontend-s3/*"
        ]
      }
    ]
  })
  depends_on = [ aws_s3_bucket_public_access_block.s3_public_access_block ]
}
