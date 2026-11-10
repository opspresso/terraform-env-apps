# What the deploy role adds for aws-asg stacks (argocd-env-projects charts/delivery/files/asg-stack.yaml). The Elastic
# Beanstalk policy already allows the EC2 calls (launch templates, security groups, RunInstances). Auto Scaling groups
# are named after the stack; load balancers and target groups get generated names, so they are scoped by the stack
# tags that CloudFormation copies to them on creation.
resource "aws_iam_role_policy" "deploy_asg" {
  name = "runway-asg"
  role = aws_iam_role.deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "OwnGroups"
        Effect   = "Allow"
        Action   = ["autoscaling:CreateAutoScalingGroup", "autoscaling:UpdateAutoScalingGroup", "autoscaling:DeleteAutoScalingGroup", "autoscaling:SetDesiredCapacity", "autoscaling:TerminateInstanceInAutoScalingGroup", "autoscaling:PutScalingPolicy", "autoscaling:DeletePolicy", "autoscaling:CreateOrUpdateTags", "autoscaling:DeleteTags", "autoscaling:AttachLoadBalancerTargetGroups", "autoscaling:DetachLoadBalancerTargetGroups"]
        Resource = "arn:${local.partition}:autoscaling:${var.region}:${local.account_id}:autoScalingGroup:*:autoScalingGroupName/${local.stack_name}-*"
      },
      {
        Sid      = "CreateTaggedLoadBalancing"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:CreateListener", "elasticloadbalancing:AddTags"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/opspresso.com/delivery-project" = "$${aws:PrincipalTag/delivery-project}"
            "aws:RequestTag/opspresso.com/delivery-env"     = "$${aws:PrincipalTag/delivery-env}"
          }
        }
      },
      {
        Sid      = "OwnLoadBalancing"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:Modify*", "elasticloadbalancing:Delete*", "elasticloadbalancing:Set*", "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags", "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets", "elasticloadbalancing:CreateListener"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/opspresso.com/delivery-project" = "$${aws:PrincipalTag/delivery-project}"
            "aws:ResourceTag/opspresso.com/delivery-env"     = "$${aws:PrincipalTag/delivery-env}"
          }
        }
      },
      {
        Sid      = "ReadLoadBalancing"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:Describe*"]
        Resource = "*"
      },
      {
        Sid      = "OwnEc2"
        Effect   = "Allow"
        Action   = ["ec2:DeleteSecurityGroup", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress", "ec2:DeleteLaunchTemplate", "ec2:CreateLaunchTemplateVersion", "ec2:ModifyLaunchTemplate"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/opspresso.com/delivery-project" = "$${aws:PrincipalTag/delivery-project}"
            "aws:ResourceTag/opspresso.com/delivery-env"     = "$${aws:PrincipalTag/delivery-env}"
          }
        }
      },
    ]
  })
}
