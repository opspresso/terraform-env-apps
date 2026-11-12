output "deploy_role_arn" {
  description = "The eb target's deployRole."
  value       = aws_iam_role.deploy.arn
}

output "service_role_arn" {
  description = "The eb target's serviceRole."
  value       = aws_iam_role.service.arn
}

output "permissions_boundary_arn" {
  description = "The eb target's permissionsBoundary."
  value       = aws_iam_policy.app_boundary.arn
}

output "artifact_bucket" {
  description = "The eb target's artifactBucket."
  value       = aws_s3_bucket.artifacts.bucket
}

output "secrets_role_arn" {
  description = "The environment's account.access.secretsRole. Null for a Target in Agent Runway's own account."
  value       = one(aws_iam_role.secrets[*].arn)
}
