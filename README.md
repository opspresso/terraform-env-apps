# terraform-env-opsp

opspresso 전용 AWS·EKS 리소스를 관리합니다. 공통 VPC·ALB·EKS·기본 노드와 addon 공통 Pod Identity는 [terraform-env-demo](https://github.com/opspresso/terraform-env-demo)가 관리합니다. `demo/`의 각 디렉터리는 독립된 Terraform root입니다.

| 디렉터리 | 용도 |
| --- | --- |
| [5-k3s](demo/5-k3s/README.md) | 삭제한 k3s 서버의 보관용 코드. 적용하지 않음 |
| [7-eks-shared](demo/7-eks-shared/README.md) | 여러 서비스가 함께 쓰는 `eks-demo` 전용 리소스: Agent 서비스·Delivery·GitLab Pod Identity 역할과 association, GitHub Actions 역할, Workspace·rovr sandbox·amd64 build NodePool |
| [8-domain-mail](demo/8-domain-mail/README.md) | `opspresso.com` Cloudflare 수신 전달과 SES SMTP 발신 |
| [8-agent-studio](demo/8-agent-studio/README.md) | Studio S3, Agent 서비스·rovr·Actions runner ECR, GitHub 게시 역할 |
| [8-agent-knowledge](demo/8-agent-knowledge/README.md) | Knowledge 원본 S3 저장소 |
| [8-agent-runway](demo/8-agent-runway/README.md) | Runway KMS, 공유 bucket, Sandbox·테넌트 IAM 역할 |
| [8-app-delivery](demo/8-app-delivery/README.md) | 앱 배포를 위한 registry 권한과 데이터 서비스 네트워크 |
| [8-runway-target](demo/8-runway-target/README.md) | Agent Runway `aws-eb` Target `demo-eb`의 deploy role, app boundary, EB 서비스 역할, source bundle bucket |
| [8-rovr](demo/8-rovr/README.md) | rovr 샌드박스 공유 캐시 EFS |
| [8-comfy-render](demo/8-comfy-render/) | Comfy Render DynamoDB, S3, 작업 큐 |
| [8-gitlab](demo/8-gitlab/README.md) | GitLab 오브젝트 스토리지 S3 |

## 준비와 실행

Terraform `1.17.1`, AWS CLI 및 대상 계정에 대한 권한이 필요합니다. `default` workspace를 사용합니다. 프로젝트에 필요한 공통 리소스는 먼저 `terraform-env-demo`에서 준비합니다. 각 디렉터리의 README에서 적용 순서와 추가 조건을 확인합니다.

```bash
cd demo/8-agent-studio
terraform init
terraform fmt -check
terraform validate
terraform plan
```

plan에서 예상한 변경만 있는지 확인한 뒤 `terraform apply`를 실행합니다. AWS 리소스나 데이터를 삭제하기 전에는 영향을 별도로 확인합니다.

## Terraform 작성 규칙

`demo/`의 모든 root는 같은 파일 배치와 작성 규칙을 따릅니다. `scripts/check-layout.sh`가 파일 배치를 검사하고, CI가 이 스크립트와 `terraform fmt -check`·`terraform validate`를 실행합니다.

### 파일 이름

파일 이름은 `NN-<주제>.tf`입니다. `NN`은 두 자리 숫자이고, 주제는 소문자·숫자·`-`로 씁니다.

| 파일 | 담는 블록 |
| --- | --- |
| `00-variables.tf` | 모든 `variable`. `variable`이 없는 root에는 두지 않습니다 |
| `02-backend.tf` | `terraform`(`required_version`·`backend`·`required_providers`)과 `provider` |
| `02-remote-state.tf` | `data "terraform_remote_state"` |
| `03-data.tf` | 여러 파일이 함께 쓰는 `data` |
| `03-locals.tf` | 여러 파일이 함께 쓰는 `locals`와 `default_tags`용 `local.tags` |
| `04-`~`98-<주제>.tf` | 주제별 리소스와 그 주제의 `data`·`locals`. 의존 순서대로 번호를 붙이고, 한 주제를 여러 파일로 나누면 같은 번호를 씁니다 |
| `99-outputs.tf` | 모든 `output` |

각 root에는 `required_version`과 같은 값의 `.terraform-version`을 둡니다.

### 코드

- `required_version`과 provider `version`은 정확한 버전으로 고정합니다(예: `"1.17.1"`, `"6.71.0"`). 범위 지정은 쓰지 않습니다.
- S3 backend는 `encrypt = true`와 `use_lockfile = true`를 씁니다.
- AWS provider는 `default_tags { tags = local.tags }`로 태그를 붙이고, `local.tags`는 `03-locals.tf`에 둡니다.
- `variable`에는 `description`과 `type`을 씁니다.
- 파일마다 `locals` 블록은 하나만 둡니다. 본문이 없는 블록은 `data "aws_caller_identity" "current" {}`처럼 한 줄로 씁니다.
- 주석은 코드만으로 알 수 없는 이유·제약·외부 연결을 설명합니다. 파일 이름이나 블록 종류를 반복하는 머리 주석(`# variable`, `# output` 등)은 쓰지 않습니다.
- 파일 이름을 바꾸거나 블록을 다른 파일로 옮겨도 state 주소는 바뀌지 않습니다. 리소스 이름을 바꿀 때는 `moved` 블록을 함께 씁니다.

## 기존 환경 이전

기존 `terraform-env-demo`에서 관리하던 root는 코드만 이 저장소로 옮겼습니다. S3 bucket·backend key·workspace·리소스 주소와 provider의 기존 `Project` 태그를 유지하므로 state 복사나 `terraform state mv`, import는 필요하지 않습니다. backend key는 임의로 변경하지 마세요.

`7-eks-shared`는 terraform-env-demo의 공통 root(`4-role`, `5-eks`, `6-eks-node`)에서 일부 리소스만 떼어 낸 root입니다. 2026-11-11에 리소스 이름을 바꾸지 않고 `import`로 state에 가져왔고, terraform-env-demo state에서는 제거했습니다.

새 checkout의 해당 디렉터리에서 `terraform init` 후 `terraform workspace show`가 `default`인지 확인하고 `terraform plan`을 검토합니다. 기존 디렉터리에서 사용한 미추적 `.tfvars`와 환경변수가 있다면 안전하게 전달해야 합니다. 민감한 값은 커밋하거나 로그에 노출하지 마세요. 기존 checkout에서 같은 root를 다시 적용하지 말고, plan에 예상치 못한 생성·변경·삭제가 보이면 적용을 중단하고 state와 입력값을 확인합니다.

모든 root는 S3 잠금(`use_lockfile = true`)을 사용합니다. state 객체와 해당 `.tflock` 객체에 대한 읽기·쓰기·삭제 권한이 필요합니다. 잠금 설정을 바꾼 checkout에서는 `terraform init -reconfigure`를 한 번 실행합니다.
