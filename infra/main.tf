# CYBERLAB - REMEDIATED TRAINING CONFIGURATION
# Static analysis only. Do not deploy.

resource "aws_security_group" "restricted_ssh" {
  name        = "cyberlab-restricted-ssh"
  description = "Restricted SSH for static analysis"

  ingress {
    description = "Documentation-only IP address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "cyberlab-secure-training-example"
}

resource "aws_s3_bucket_public_access_block" "enabled" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "bucket_key" {
  description             = "CyberLab S3 encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_iam_policy" "scoped_read_only" {
  name = "cyberlab-scoped-read-only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.secure_bucket.arn}/approved/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = aws_kms_key.bucket_key.arn
      }
    ]
  })
}