# The calling root pins the Terraform and provider versions and configures the provider of the Target account.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
