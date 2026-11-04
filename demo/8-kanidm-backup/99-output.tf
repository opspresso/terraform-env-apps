output "vault" {
  value = aws_backup_vault.kanidm.name
}

output "plan_id" {
  value = aws_backup_plan.kanidm.id
}
