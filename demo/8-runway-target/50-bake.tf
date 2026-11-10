# The image bake role of this account's aws-asg Target. The image-bake Workflow (ServiceAccount delivery-target) assumes
# it to run packer (argocd-env-projects charts/delivery/files/images/vm-node.pkr.hcl): a temporary instance, security
# group, key pair and instance profile, reached through Session Manager, become the AMI agent-runway-<name>-<version>.
resource "aws_iam_role" "bake" {
  name                 = "agent-runway-target-bake"
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = local.target_step_role_arn }
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow"
        Principal = { AWS = local.target_step_role_arn }
        Action    = "sts:TagSession"
        Condition = { "ForAllValues:StringEquals" = { "aws:TagKeys" = local.pod_identity_tag_keys } }
      },
    ]
  })
}

resource "aws_iam_role_policy" "bake" {
  name = "packer"
  role = aws_iam_role.bake.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Build"
        Effect = "Allow"
        Action = [
          "ec2:Describe*", "ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:CreateTags",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateKeyPair", "ec2:DeleteKeyPair", "ec2:CreateImage", "ec2:RegisterImage", "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot", "ec2:DeleteVolume", "ec2:ModifyImageAttribute", "ec2:ModifyInstanceAttribute",
          "ec2:AttachVolume", "ec2:DetachVolume", "ec2:GetPasswordData",
        ]
        Resource = "*"
      },
      {
        # The boot volume is encrypted with the account's default EBS key.
        Sid       = "EncryptedVolumes"
        Effect    = "Allow"
        Action    = ["kms:CreateGrant", "kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey*", "kms:ReEncrypt*"]
        Resource  = "*"
        Condition = { StringEquals = { "kms:ViaService" = "ec2.${var.region}.amazonaws.com" } }
      },
      {
        Sid      = "TemporaryInstanceProfile"
        Effect   = "Allow"
        Action   = ["iam:CreateRole", "iam:DeleteRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRole", "iam:GetRolePolicy", "iam:TagRole", "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile", "iam:TagInstanceProfile"]
        Resource = ["arn:${local.partition}:iam::${local.account_id}:role/packer-*", "arn:${local.partition}:iam::${local.account_id}:instance-profile/packer-*"]
      },
      {
        Sid       = "PassTemporaryRole"
        Effect    = "Allow"
        Action    = ["iam:PassRole"]
        Resource  = "arn:${local.partition}:iam::${local.account_id}:role/packer-*"
        Condition = { StringEquals = { "iam:PassedToService" = "ec2.amazonaws.com" } }
      },
      {
        Sid      = "SessionManager"
        Effect   = "Allow"
        Action   = ["ssm:StartSession", "ssm:TerminateSession", "ssm:DescribeInstanceInformation", "ssm:GetConnectionStatus"]
        Resource = "*"
      },
    ]
  })
}
