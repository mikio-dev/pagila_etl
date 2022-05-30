resource "aws_s3_bucket" "staging_bucket" {
  bucket = var.s3_staging_bucket_name
  tags = {
    Name = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "staging_bucket" {
  bucket = aws_s3_bucket.staging_bucket.id
}

resource "aws_s3_bucket" "mwaa_bucket" {
  bucket = var.s3_airflow_bucket_name
  tags = {
    Name = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa_bucket" {
  bucket                  = aws_s3_bucket.mwaa_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "mwaa_bucket" {
  bucket = aws_s3_bucket.mwaa_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "mwaa_bucket" {
  bucket = aws_s3_bucket.mwaa_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object" "mwaa_dags" {
  bucket = aws_s3_bucket.mwaa_bucket.id
  key    = "dags/"
  tags = {
    Name = var.project_name
  }
}

resource "aws_s3_bucket_object" "mwaa_plugins" {
  bucket = aws_s3_bucket.mwaa_bucket.id
  key    = "plugins.zip"
  source = "./plugins.zip"
  tags = {
    Name = var.project_name
  }
}
