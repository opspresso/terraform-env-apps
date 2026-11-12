# The secrets role of a Target in another account (agent-platform docs/APP_DELIVERY.md "외부 계정"): Agent Runway
# assumes it with the environment's external ID and writes the Variables of this account's targets to SSM
# /agent-runway/<target>/<slug>/<env>/ with the target's key. Its access check writes and deletes
# /agent-runway/<target>/_runway/access-check. The instances read their own environment's path with their stack role.
resource "aws_iam_role" "secrets" {
  count = var.external_id == null ? 0 : 1

  name                 = "agent-runway-target-secrets"
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = var.runway_role_arn }
        Action    = "sts:AssumeRole"
        Condition = local.external_id_condition
      },
      {
        Effect    = "Allow"
        Principal = { AWS = var.runway_role_arn }
        Action    = "sts:TagSession"
        # EKS Pod Identity session tags are transitive, so the chained session carries them.
        Condition = {
          "ForAllValues:StringEquals" = { "aws:TagKeys" = local.pod_identity_tag_keys }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "secrets" {
  count = var.external_id == null ? 0 : 1

  name = "variables"
  role = aws_iam_role.secrets[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TargetVariables"
        Effect   = "Allow"
        Action   = ["ssm:PutParameter", "ssm:GetParameters", "ssm:DeleteParameters"]
        Resource = [for name in var.target_names : "arn:${local.partition}:ssm:${local.region}:${local.account_id}:parameter/agent-runway/${name}/*"]
      },
      {
        Sid       = "VariableKey"
        Effect    = "Allow"
        Action    = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
        Resource  = var.secrets_key_arn
        Condition = { StringEquals = { "kms:ViaService" = "ssm.${local.region}.amazonaws.com" } }
      },
    ]
  })
}
