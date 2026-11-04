# terraform-env-apps

프로젝트별 AWS 리소스를 관리합니다. 공통 VPC·EKS·Pod Identity 역할과 연결은 [terraform-env-demo](https://github.com/opspresso/terraform-env-demo)가 관리합니다. `demo/`의 각 디렉터리는 독립된 Terraform root입니다.

| 디렉터리 | 용도 |
| --- | --- |
| [8-agent-studio](demo/8-agent-studio/README.md) | Studio S3, Agent 서비스와 rovr ECR, GitHub 게시 역할 |
| [8-agent-knowledge](demo/8-agent-knowledge/README.md) | Knowledge 원본 S3 저장소 |
| [8-agent-runway](demo/8-agent-runway/README.md) | Runway KMS, 공유 bucket, Sandbox·테넌트 IAM 역할 |
| [8-app-delivery](demo/8-app-delivery/README.md) | 앱 배포를 위한 registry 권한과 데이터 서비스 네트워크 |
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

## 기존 환경 이전

기존 `terraform-env-demo`에서 관리하던 root는 코드만 이 저장소로 옮겼습니다. S3 bucket·backend key·workspace·리소스 주소와 provider의 기존 `Project` 태그를 유지하므로 state 복사나 `terraform state mv`, import는 필요하지 않습니다. `8-agent-runway`의 backend key에는 이전 이름 `agent-delivery-demo`가 남아 있습니다. 임의로 변경하지 마세요.

새 checkout의 해당 디렉터리에서 `terraform init` 후 `terraform workspace show`가 `default`인지 확인하고 `terraform plan`을 검토합니다. 기존 디렉터리에서 사용한 미추적 `.tfvars`와 환경변수가 있다면 안전하게 전달해야 합니다. 민감한 값은 커밋하거나 로그에 노출하지 마세요. 기존 checkout에서 같은 root를 다시 적용하지 말고, plan에 예상치 못한 생성·변경·삭제가 보이면 적용을 중단하고 state와 입력값을 확인합니다.

각 root의 기존 S3 잠금 설정을 유지합니다. `use_lockfile = true`인 root는 state 객체와 해당 `.tflock` 객체에 대한 읽기·쓰기·삭제 권한이 필요합니다. `8-comfy-render`는 기존과 같이 S3 잠금을 사용하지 않으므로 동시 실행하지 마세요.
