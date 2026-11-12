# 다른 계정 eb Target의 앱 instance가 이 registry의 Project 이미지를 pull하게 하는 registry policy입니다.
# repository는 Delivery registry 단계가 그때그때 만들고 repository policy를 붙이지 않으므로, 계정의 registry policy(scope V2)가
# 모든 `projects/*` repository에 적용합니다. 허용하는 주체는 Target stack의 instance 역할 `runway-<project>-<env>-app`뿐입니다
# (argocd-env-projects `charts/delivery/files/eb-stack.yaml` InstanceRole). 그 역할의 정책과 boundary가 자기 Project의
# repository 하나로 다시 좁힙니다. registry policy는 계정에 하나이므로 다른 registry 권한도 이 리소스에 추가합니다.
resource "aws_ecr_registry_policy" "target_pull" {
  count = length(var.target_account_ids) > 0 ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "TargetInstancePull"
      Effect    = "Allow"
      Principal = { AWS = [for id in var.target_account_ids : "arn:aws:iam::${id}:root"] }
      Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
      Resource  = "arn:aws:ecr:${var.region}:${local.account_id}:repository/projects/*"
      Condition = {
        ArnLike = { "aws:PrincipalArn" = [for id in var.target_account_ids : "arn:aws:iam::${id}:role/runway-*-app"] }
      }
    }]
  })
}
