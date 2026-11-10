# remote

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "terraform-workshop-396608815058"
    key    = "backend/demo/vpc-demo/terraform.tfstate"
  }
}

data "aws_route53_zone" "apps" {
  name         = var.hosted_zone
  private_zone = false
}

data "aws_acm_certificate" "apps" {
  domain      = var.domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_kms_alias" "secrets" {
  name = var.secrets_key_alias
}
