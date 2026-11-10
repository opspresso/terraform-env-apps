# The permissions boundary of every role a Runway stack creates (argocd-env-projects charts/delivery
# files/eb-stack.yaml InstanceRole). The deploy role may create roles only with this boundary, so a stack can never
# grant an instance more than this: the Elastic Beanstalk web tier, Agent Runway Variables and Project images.
# The stack's own policy narrows it to one environment's SSM path and one Project repository.
resource "aws_iam_policy" "app_boundary" {
  name        = "agent-runway-app-boundary"
  description = "Upper limit of the instance roles of Agent Runway Target stacks"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "BeanstalkBuckets"
        Effect   = "Allow"
        Action   = ["s3:Get*", "s3:List*", "s3:PutObject"]
        Resource = ["arn:${local.partition}:s3:::elasticbeanstalk-*", "arn:${local.partition}:s3:::elasticbeanstalk-*/*"]
      },
      {
        Sid      = "BeanstalkLogs"
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:DescribeLogStreams", "logs:DescribeLogGroups"]
        Resource = "arn:${local.partition}:logs:*:${local.account_id}:log-group:/aws/elasticbeanstalk*"
      },
      {
        Sid      = "BeanstalkHealth"
        Effect   = "Allow"
        Action   = ["elasticbeanstalk:PutInstanceStatistics"]
        Resource = ["arn:${local.partition}:elasticbeanstalk:*:${local.account_id}:application/*", "arn:${local.partition}:elasticbeanstalk:*:${local.account_id}:environment/*"]
      },
      {
        Sid      = "Tracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords", "xray:GetSamplingRules", "xray:GetSamplingTargets", "xray:GetSamplingStatisticSummaries"]
        Resource = "*"
      },
      {
        Sid      = "Variables"
        Effect   = "Allow"
        Action   = ["ssm:GetParametersByPath"]
        Resource = [for name in [var.target_name, var.amd64_target_name, var.asg_target_name] : "arn:${local.partition}:ssm:${var.region}:${local.account_id}:parameter/agent-runway/${name}/*"]
      },
      {
        Sid       = "VariableKey"
        Effect    = "Allow"
        Action    = ["kms:Decrypt"]
        Resource  = data.aws_kms_alias.secrets.target_key_arn
        Condition = { StringEquals = { "kms:ViaService" = "ssm.${var.region}.amazonaws.com" } }
      },
      {
        # aws-asg instances signal their own stack (cfn-signal) when the app is healthy.
        Sid      = "StackSignal"
        Effect   = "Allow"
        Action   = ["cloudformation:SignalResource"]
        Resource = "arn:${local.partition}:cloudformation:${var.region}:${local.account_id}:stack/runway-*/*"
      },
      {
        Sid      = "RegistryLogin"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid      = "ProjectImages"
        Effect   = "Allow"
        Action   = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
        Resource = "arn:${local.partition}:ecr:*:*:repository/projects/*"
      },
    ]
  })
}
