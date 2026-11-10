data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

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
