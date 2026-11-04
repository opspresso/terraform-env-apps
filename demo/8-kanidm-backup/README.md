# 8-kanidm-backup

Kanidm(`argocd-env-addons` `charts/kanidm`)의 EBS 볼륨을 AWS Backup으로 매일 스냅샷해 클러스터 밖에 보관합니다.

- kanidmd는 03:00 KST에 같은 볼륨의 `/data/backups/`로 online backup을 씁니다. 이 plan은 04:00 KST에 스냅샷하므로
  모든 스냅샷에 일관된 backup 파일이 들어 있습니다.
- 대상은 태그로 고릅니다: `kubernetes.io/created-for/pvc/namespace = addon-kanidm`, `KubernetesCluster = eks-demo`.
  PVC를 다시 만들어도 이 root를 바꿀 필요가 없습니다.
- 보관 기간은 `retention_days`(기본 30일)입니다. vault는 `kanidm-demo`입니다.

## 복원

1. AWS Backup 콘솔 또는 `aws backup start-restore-job`으로 스냅샷에서 새 EBS 볼륨을 만듭니다.
2. 그 볼륨을 임시 Pod에 붙여 `/data/backups/`의 파일을 꺼냅니다.
3. `charts/kanidm/README.md`의 '백업'에 따라 `kanidmd database restore`로 복원합니다.

```bash
terraform init
terraform plan
terraform apply
```
