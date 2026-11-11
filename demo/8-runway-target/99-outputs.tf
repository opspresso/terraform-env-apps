# What an administrator enters for an Agent Runway environment of this account: its account and its eb target. They
# hold no secret value. The tiers pair var.instance_types and var.amd64_instance_types in the order small, medium, large.
output "account" {
  value = {
    id     = local.account_id
    region = var.region
  }
}

output "eb_target" {
  value = {
    type          = "eb"
    name          = var.target_name
    architectures = ["arm64", "amd64"]
    domain        = var.domain
    sizes = {
      small  = { instanceTypes = { arm64 = var.instance_types[0], amd64 = var.amd64_instance_types[0] }, min = 1, max = 1 }
      medium = { instanceTypes = { arm64 = var.instance_types[1], amd64 = var.amd64_instance_types[1] }, min = 1, max = 2 }
      large  = { instanceTypes = { arm64 = var.instance_types[2], amd64 = var.amd64_instance_types[2] }, min = 2, max = 4 }
    }
    deployRole          = aws_iam_role.deploy.arn
    artifactBucket      = aws_s3_bucket.artifacts.bucket
    solutionStack       = var.solution_stack
    serviceRole         = aws_iam_role.service.arn
    permissionsBoundary = aws_iam_policy.app_boundary.arn
    vpcId               = data.terraform_remote_state.vpc.outputs.vpc_id
    instanceSubnets     = data.terraform_remote_state.vpc.outputs.private_subnets
    loadBalancerSubnets = data.terraform_remote_state.vpc.outputs.public_subnets
    certificateArn      = data.aws_acm_certificate.apps.arn
    hostedZoneId        = data.aws_route53_zone.apps.zone_id
    secretsKeyArn       = data.aws_kms_alias.secrets.target_key_arn
  }
}
