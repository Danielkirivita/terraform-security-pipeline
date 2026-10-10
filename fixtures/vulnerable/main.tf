# CYBERLAB TRAINING ONLY - DO NOT DEPLOY

resource "aws_security_group" "insecure_ssh" {
  name        = "cyberlab-public-ssh"
  description = "Intentionally vulnerable SSH configuration"

  ingress {
    description = "SSH open to the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "insecure_admin" {
  name = "cyberlab-overprivileged-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "cyberlab-insecure-training-example"
}

resource "aws_s3_bucket_public_access_block" "disabled" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}