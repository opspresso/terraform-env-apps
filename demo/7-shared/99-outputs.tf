output "role_arns" {
  description = "Pod Identity role ARN by key."
  value       = { for key, role in aws_iam_role.this : key => role.arn }
}

output "github_ecr_public_pull_role_arn" {
  description = "argocd-env-addons CI 가 public.ecr.aws chart 를 인증해서 받을 때 assume 하는 역할."
  value       = aws_iam_role.github_ecr_public_pull.arn
}
