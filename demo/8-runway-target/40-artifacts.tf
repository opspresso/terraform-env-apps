# Source bundles of the Target's Deployments: <project>/<environment>/<Deployment ID>.zip. A bundle holds no secret
# value. Elastic Beanstalk copies the bundle of each application version, so an old bundle can expire.
resource "aws_s3_bucket" "artifacts" {
  bucket = "agent-runway-${var.target_name}-${local.account_id}"
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    id     = "expire-bundles"
    status = "Enabled"
    filter {}
    expiration {
      days = 90
    }
  }
}
