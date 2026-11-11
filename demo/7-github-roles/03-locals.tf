locals {
  # The backend block cannot read locals and repeats this region.
  region = "ap-northeast-2"

  tags = {
    Environment = "demo"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-opsp/demo/7-github-roles"
  }
}
