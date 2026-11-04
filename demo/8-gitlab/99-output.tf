output "buckets" {
  description = "Bucket name per GitLab object type."
  value       = { for k, b in aws_s3_bucket.this : k => b.bucket }
}

output "bucket_arns" {
  value = [for b in aws_s3_bucket.this : b.arn]
}
