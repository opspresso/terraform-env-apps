# The Target runs in Agent Runway's own account, so its deploy role needs no external ID and Agent Runway writes the
# Variables with its own role (no secrets role).
module "target" {
  source = "../../modules/runway-target"

  target_names         = [var.target_name, var.amd64_target_name]
  target_step_role_arn = local.target_step_role_arn
  domain               = var.domain
  hosted_zone_id       = data.aws_route53_zone.apps.zone_id
  secrets_key_arn      = data.aws_kms_alias.secrets.target_key_arn
  artifact_bucket      = "agent-runway-${var.target_name}-${local.account_id}"
}

# The resources moved into the shared module (modules/runway-target) without being replaced.
moved {
  from = aws_iam_policy.app_boundary
  to   = module.target.aws_iam_policy.app_boundary
}

moved {
  from = aws_iam_role.deploy
  to   = module.target.aws_iam_role.deploy
}

moved {
  from = aws_iam_role_policy_attachment.deploy_beanstalk
  to   = module.target.aws_iam_role_policy_attachment.deploy_beanstalk
}

moved {
  from = aws_iam_role_policy.deploy
  to   = module.target.aws_iam_role_policy.deploy
}

moved {
  from = aws_iam_role_policy.deploy_isolation
  to   = module.target.aws_iam_role_policy.deploy_isolation
}

moved {
  from = aws_iam_role.service
  to   = module.target.aws_iam_role.service
}

moved {
  from = aws_iam_role_policy_attachment.service
  to   = module.target.aws_iam_role_policy_attachment.service
}

moved {
  from = aws_s3_bucket.artifacts
  to   = module.target.aws_s3_bucket.artifacts
}

moved {
  from = aws_s3_bucket_public_access_block.artifacts
  to   = module.target.aws_s3_bucket_public_access_block.artifacts
}

moved {
  from = aws_s3_bucket_ownership_controls.artifacts
  to   = module.target.aws_s3_bucket_ownership_controls.artifacts
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.artifacts
  to   = module.target.aws_s3_bucket_server_side_encryption_configuration.artifacts
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.artifacts
  to   = module.target.aws_s3_bucket_lifecycle_configuration.artifacts
}
