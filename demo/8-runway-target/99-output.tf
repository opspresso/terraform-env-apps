# The Target as Agent Runway registers it (agent-platform docs/DELIVERY_V3.md D1). It holds no secret value.
output "target" {
  value = {
    name                = var.target_name
    kind                = "aws-eb"
    architecture        = "arm64"
    domain              = var.domain
    account             = local.account_id
    region              = var.region
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
    instanceTypes       = var.instance_types
    defaultInstanceType = var.instance_types[0]
  }
}
