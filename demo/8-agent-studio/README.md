# Agent Studio 인프라

Agent Studio S3, Agent 서비스 ECR, GitHub Actions 게시 역할을 관리한다. 이전 k3s 인스턴스 코드는
[`terraform-env-demo/demo/5-k3s`](https://github.com/opspresso/terraform-env-demo/tree/main/demo/5-k3s)에 보관한다.

## Agent 배포 권한

ECR 저장소는 Studio·Memory·Knowledge·Forge·Models·Delivery와 rovr, 일곱 개다. GitHub Actions 역할
`github--<repository>-ecr`은 해당 저장소의 이미지 게시만 허용한다.
Forge와 rovr는 서버와 sandbox 이미지를 같은 저장소의 서로 다른 태그(`v*`, `sandbox-v*`)로 게시한다.
`ecr:GetAuthorizationToken`만 AWS API 계약에 따라 `Resource="*"`이며,
이미지 작업은 각 저장소 ARN으로 제한한다.

Knowledge·Forge·Models·Delivery·rovr는 GitHub API가 반환한 immutable subject prefix와 `refs/tags/v*`만 신뢰한다.
`main`, Pull Request, environment subject와 다른 저장소는 허용하지 않는다.
GitHub OIDC의 `aud`는 `sts.amazonaws.com`이어야 한다.
기존 Studio·Memory 역할은 이번 Terraform 인수에서 trust와 권한을 그대로 보존한다.
두 역할에는 이전 이름 형식·immutable 형식과 `main`·`v*` 태그가 이미 허용되어 있다.

기존 Studio의 role·managed policy·attachment와 Memory의 role·inline policy는
`91-github-ecr.tf`의 import block으로 가져온다. Memory inline policy를 managed policy로
전환하거나 잠시 분리하지 않는다. 인수 plan의 기존 IAM 변경은 관리 태그뿐이어야 하며,
기존 ECR·S3·EC2의 재생성이나 권한 변경이 있으면 적용하지 않는다.

## GitHub Actions runner image

`92-actions-runner-ecr.tf`는 ARC runner scale set `eks-arm64`(`argocd-env-addons` `charts/arc-runners`)의
runner image 저장소 `actions-runner`와 게시 역할 `github--agent-platform-runner-ecr`을 만든다.
`agent-platform`의 `runner/Dockerfile`을 `main`에서 build해 게시하며, 역할은 그 저장소의 immutable subject와
`refs/heads/main`만 신뢰한다. EKS 노드는 노드 역할의 ECR pull 권한으로 image를 받는다.
tag는 `<runner 버전>-<commit>`이며 변경할 수 없다(`IMMUTABLE`). 고정된 tag가 지워지지 않도록 lifecycle 규칙은 tag 없는 image만 하루 뒤 삭제한다.

Agent Knowledge 버킷은 [`../8-agent-knowledge`](../8-agent-knowledge/README.md)가 관리한다.
이 root의 릴리즈 권한 변경은 그 버킷·EKS 클러스터·노드를 만들지 않는다.

## 계획 확인

Terraform `1.17.1`과 AWS provider `6.71.0`을 사용한다. `default` workspace에서 실행한다.

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -input=false -out=terraform.tfplan
```

OIDC subject 형식은 [GitHub 문서](https://docs.github.com/en/actions/reference/security/oidc)를,
게시 권한은 [AWS ECR 문서](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html)를 따른다.
