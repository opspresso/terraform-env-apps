locals {
  account_id = data.aws_caller_identity.current.account_id
  azs        = sort(keys(var.az_subnets))

  tags = {
    Environment = "stg"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-opsp/demo/8-runway-target-two"
  }
}
