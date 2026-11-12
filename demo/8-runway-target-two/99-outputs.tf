# What an administrator enters for the Agent Runway environment of this account: its account and its eb target. They
# hold no secret value; Agent Runway adds account.access.externalId itself. The tiers use var.amd64_instance_types in
# the order small, medium, large.
output "account" {
  value = {
    id     = local.account_id
    region = var.region
    access = { secretsRole = module.target.secrets_role_arn }
  }
}

output "eb_target" {
  value = {
    type          = "eb"
    name          = var.target_name
    architectures = ["amd64"]
    domain        = var.domain
    sizes = {
      small  = { instanceTypes = { amd64 = var.amd64_instance_types[0] }, min = 1, max = 1 }
      medium = { instanceTypes = { amd64 = var.amd64_instance_types[1] }, min = 1, max = 2 }
      large  = { instanceTypes = { amd64 = var.amd64_instance_types[2] }, min = 2, max = 4 }
    }
    deployRole          = module.target.deploy_role_arn
    artifactBucket      = module.target.artifact_bucket
    solutionStack       = var.solution_stack
    serviceRole         = module.target.service_role_arn
    permissionsBoundary = module.target.permissions_boundary_arn
    vpcId               = aws_vpc.this.id
    instanceSubnets     = [for az in local.azs : aws_subnet.private[az].id]
    loadBalancerSubnets = [for az in local.azs : aws_subnet.public[az].id]
    certificateArn      = aws_acm_certificate_validation.apps.certificate_arn
    hostedZoneId        = aws_route53_zone.apps.zone_id
    secretsKeyArn       = aws_kms_key.variables.arn
  }
}

output "egress_ip" {
  description = "The public address of the instances' outbound traffic (the NAT gateway), for allow lists of external services."
  value       = aws_eip.nat.public_ip
}
