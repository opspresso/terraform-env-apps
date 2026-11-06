# GitHub Actions runner image for the ARC scale set eks-arm64
# (argocd-env-addons charts/arc-runners). agent-platform builds it from
# runner/Dockerfile on main; EKS nodes pull it with the node role.
resource "aws_ecr_repository" "actions_runner" {
  name = "actions-runner"
  # Tags carry the commit (<runner version>-<sha>); a pinned tag never changes.
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "actions-runner"
  }
}

# Runner Pods pin one tag, so tagged images are kept. Only untagged layers
# left by an interrupted push expire.
resource "aws_ecr_lifecycle_policy" "actions_runner" {
  repository = aws_ecr_repository.actions_runner.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after one day"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 1
      }
      action = { type = "expire" }
    }]
  })
}

# Only agent-platform main-branch runs can publish the runner image.
resource "aws_iam_role" "github_actions_runner_ecr" {
  name                 = "github--agent-platform-runner-ecr"
  description          = "agent-platform publishes the ARC runner image from main"
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:opspresso@38965494/agent-platform@1420059785:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    Name      = "github--agent-platform-runner-ecr"
    ManagedBy = "Terraform"
    Project   = "agent-platform"
  }
}

resource "aws_iam_role_policy" "github_actions_runner_ecr" {
  name = "ecr-push-actions-runner"
  role = aws_iam_role.github_actions_runner_ecr.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "ecr:GetAuthorizationToken", Resource = "*" },
      {
        Effect   = "Allow"
        Action   = concat(local.github_ecr_push_actions, ["ecr:GetDownloadUrlForLayer"])
        Resource = aws_ecr_repository.actions_runner.arn
      },
    ]
  })
}

output "actions_runner_repository_url" {
  value = aws_ecr_repository.actions_runner.repository_url
}

output "actions_runner_publisher_role_arn" {
  value = aws_iam_role.github_actions_runner_ecr.arn
}
