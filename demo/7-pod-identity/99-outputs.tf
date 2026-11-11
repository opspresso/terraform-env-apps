output "role_arns" {
  description = "Pod Identity role ARN by key."
  value       = { for key, role in aws_iam_role.this : key => role.arn }
}
