# The deploy role of this Target. The app-deploy-eb and app-remove-eb steps (ServiceAccount delivery-target) assume it
# with the session tags delivery-project and delivery-env, and the policy lets that session change only the stack
# runway-<project>-<environment>, the roles and instance profiles named runway-* with the app boundary, the source
# bundles of that environment and the app records of the Target zone.
resource "aws_iam_role" "deploy" {
  name                 = "agent-runway-target-deploy"
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = local.target_step_role_arn }
        Action    = "sts:AssumeRole"
        Condition = {
          StringLike = {
            "aws:RequestTag/delivery-project" = "?*"
            "aws:RequestTag/delivery-env"     = "?*"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { AWS = local.target_step_role_arn }
        Action    = "sts:TagSession"
        Condition = {
          "ForAllValues:StringEquals" = { "aws:TagKeys" = concat(["delivery-project", "delivery-env"], local.pod_identity_tag_keys) }
        }
      },
    ]
  })
}

# Elastic Beanstalk creates the environment's Auto Scaling group, load balancer, security groups and alarms with the
# caller's permissions, so the deploy role needs its administrator policy.
resource "aws_iam_role_policy_attachment" "deploy_beanstalk" {
  role       = aws_iam_role.deploy.name
  policy_arn = "arn:${local.partition}:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

resource "aws_iam_role_policy" "deploy" {
  name = "runway-stack"
  role = aws_iam_role.deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "OwnStack"
        Effect   = "Allow"
        Action   = ["cloudformation:CreateStack", "cloudformation:UpdateStack", "cloudformation:DeleteStack", "cloudformation:CreateChangeSet", "cloudformation:ExecuteChangeSet", "cloudformation:DescribeChangeSet", "cloudformation:DeleteChangeSet", "cloudformation:DescribeStacks", "cloudformation:DescribeStackEvents", "cloudformation:GetTemplateSummary"]
        Resource = "arn:${local.partition}:cloudformation:${var.region}:${local.account_id}:stack/${local.stack_name}/*"
      },
      {
        Sid      = "Templates"
        Effect   = "Allow"
        Action   = ["cloudformation:ValidateTemplate", "cloudformation:GetTemplateSummary"]
        Resource = "*"
      },
      {
        Sid       = "BoundedRoles"
        Effect    = "Allow"
        Action    = ["iam:CreateRole", "iam:PutRolePolicy", "iam:AttachRolePolicy", "iam:DeleteRolePolicy", "iam:DetachRolePolicy", "iam:PutRolePermissionsBoundary"]
        Resource  = "arn:${local.partition}:iam::${local.account_id}:role/${local.stack_name}-*"
        Condition = { StringEquals = { "iam:PermissionsBoundary" = aws_iam_policy.app_boundary.arn } }
      },
      {
        Sid      = "StackRoles"
        Effect   = "Allow"
        Action   = ["iam:GetRole", "iam:GetRolePolicy", "iam:DeleteRole", "iam:TagRole", "iam:UntagRole", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies"]
        Resource = "arn:${local.partition}:iam::${local.account_id}:role/${local.stack_name}-*"
      },
      {
        Sid      = "StackInstanceProfiles"
        Effect   = "Allow"
        Action   = ["iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile", "iam:TagInstanceProfile"]
        Resource = "arn:${local.partition}:iam::${local.account_id}:instance-profile/${local.stack_name}-*"
      },
      {
        Sid      = "PassStackRoles"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = ["arn:${local.partition}:iam::${local.account_id}:role/${local.stack_name}-*", aws_iam_role.service.arn]
        Condition = {
          StringEquals = { "iam:PassedToService" = ["ec2.amazonaws.com", "elasticbeanstalk.amazonaws.com"] }
        }
      },
      {
        Sid      = "SourceBundles"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.artifacts.arn}/$${aws:PrincipalTag/delivery-project}/$${aws:PrincipalTag/delivery-env}/*"
      },
      {
        Sid      = "AppRecords"
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets", "route53:GetHostedZone", "route53:ListResourceRecordSets"]
        Resource = data.aws_route53_zone.apps.arn
        Condition = {
          "ForAllValues:StringLike" = { "route53:ChangeResourceRecordSetsNormalizedRecordNames" = ["*.${var.domain}"] }
        }
      },
      {
        Sid      = "RecordChanges"
        Effect   = "Allow"
        Action   = ["route53:GetChange"]
        Resource = "arn:${local.partition}:route53:::change/*"
      },
    ]
  })
}
