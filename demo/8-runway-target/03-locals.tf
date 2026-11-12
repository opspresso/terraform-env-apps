locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  # The Pod Identity role of the VM Target Workflow steps (demo/7-eks-shared `pod-role--delivery-target`).
  target_step_role_arn = "arn:${local.partition}:iam::${var.management_account_id}:role/pod-role--delivery-target"

  tags = {
    Environment = "demo"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-apps/demo/8-runway-target"
  }
}
