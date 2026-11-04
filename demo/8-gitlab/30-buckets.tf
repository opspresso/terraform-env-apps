# Object storage of the GitLab chart (argocd-env-addons charts/gitlab). GitLab needs one bucket per object type:
# a backup restore fails when two types share a bucket.
locals {
  buckets = {
    artifacts = "opspresso-gitlab-artifacts"
    lfs       = "opspresso-gitlab-lfs"
    uploads   = "opspresso-gitlab-uploads"
    packages  = "opspresso-gitlab-packages"
    backups   = "opspresso-gitlab-backups"
    # backup-utility stages archives here during backup and restore.
    tmp = "opspresso-gitlab-tmp"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket = each.value

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = false
    blocked_encryption_types = ["SSE-C"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = [each.value.arn, "${each.value.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  rule {
    id     = "abort-incomplete-uploads-7d"
    status = "Enabled"
    filter {
      prefix = ""
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # backup-utility leaves nothing here that a later run needs.
  dynamic "rule" {
    for_each = each.key == "tmp" ? [1] : []
    content {
      id     = "expire-tmp-7d"
      status = "Enabled"
      filter {
        prefix = ""
      }
      expiration {
        days = 7
      }
    }
  }
}
