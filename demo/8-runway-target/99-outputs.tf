# The Target as Agent Runway registers it (agent-platform docs/DELIVERY_V3.md D1). It holds no secret value.
locals {
  eb_target = {
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

output "target" {
  value = local.eb_target
}

# The amd64 aws-eb Target: the same setup as target with amd64 instances.
output "amd64_target" {
  value = merge(local.eb_target, {
    name                = var.amd64_target_name
    architecture        = "amd64"
    instanceTypes       = var.amd64_instance_types
    defaultInstanceType = var.amd64_instance_types[0]
  })
}

# The aws-asg Target as Agent Runway registers it. `imageId` is not here: Agent Runway sets it from the golden image
# that image-bake built.
output "asg_target" {
  value = {
    name                = var.asg_target_name
    kind                = "aws-asg"
    architecture        = "arm64"
    domain              = var.domain
    account             = local.account_id
    region              = var.region
    deployRole          = aws_iam_role.deploy.arn
    bakeRole            = aws_iam_role.bake.arn
    bakeSubnet          = data.terraform_remote_state.vpc.outputs.private_subnets[0]
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
