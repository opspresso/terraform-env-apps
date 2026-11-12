# The roles, boundary and bucket of the eb target. The management account's roles (demo/7-eks-shared) reach them only
# with Agent Runway's external ID: the Workflow steps assume the deploy role, and Agent Runway assumes the secrets role.
module "target" {
  source = "../../modules/runway-target"

  target_names         = [var.target_name]
  target_step_role_arn = "arn:aws:iam::${var.management_account_id}:role/pod-role--delivery-target"
  runway_role_arn      = "arn:aws:iam::${var.management_account_id}:role/pod-role--agent-runway"
  external_id          = var.runway_external_id
  domain               = var.domain
  hosted_zone_id       = aws_route53_zone.apps.zone_id
  secrets_key_arn      = aws_kms_key.variables.arn
  artifact_bucket      = "agent-runway-${var.target_name}-${local.account_id}"
}
