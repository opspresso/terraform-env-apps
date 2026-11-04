# 8-gitlab

GitLab(`argocd-env-addons` `charts/gitlab`)의 오브젝트 스토리지 S3 버킷을 정의합니다.
GitLab은 오브젝트 종류마다 다른 버킷을 써야 합니다. 두 종류가 한 버킷을 쓰면 백업 복원이 실패합니다.

| 키 | 버킷 | GitLab 설정 |
| --- | --- | --- |
| `artifacts` | `opspresso-gitlab-artifacts` | `global.appConfig.artifacts` |
| `lfs` | `opspresso-gitlab-lfs` | `global.appConfig.lfs` |
| `uploads` | `opspresso-gitlab-uploads` | `global.appConfig.uploads` |
| `packages` | `opspresso-gitlab-packages` | `global.appConfig.packages` |
| `backups` | `opspresso-gitlab-backups` | `global.appConfig.backups.bucket` |
| `tmp` | `opspresso-gitlab-tmp` | `global.appConfig.backups.tmpBucket`. 7일 뒤 만료 |

이 root는 IAM 역할과 Pod Identity association을 만들지 않습니다. 역할 `pod-role--gitlab`은
`terraform-env-demo/demo/4-role`, association(`addon-gitlab`/`gitlab`)은 `terraform-env-demo/demo/5-eks`가 만듭니다.

공개 접근과 TLS가 아닌 요청을 차단하고 AES256 서버 암호화를 사용합니다. 모든 버킷은 `prevent_destroy`로 보호합니다.

```bash
terraform init
terraform plan
terraform apply
```
