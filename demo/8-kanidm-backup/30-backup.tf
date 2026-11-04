# Daily snapshot of the Kanidm volume (argocd-env-addons charts/kanidm) outside
# the cluster. kanidmd writes its online backup to the same volume at 03:00 KST;
# this snapshot runs at 04:00 KST, so every snapshot holds a consistent backup
# file even if the live database is mid-write.
resource "aws_backup_vault" "kanidm" {
  name = "kanidm-demo"
}

resource "aws_backup_plan" "kanidm" {
  name = "kanidm-demo"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.kanidm.name
    schedule          = "cron(0 19 * * ? *)" # 04:00 KST
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.retention_days
    }
  }
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "backup--kanidm-demo"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# The EBS CSI driver tags each volume with its PVC namespace. Only the Kanidm
# volume of eks-demo matches; a recreated PVC is selected without a change here.
resource "aws_backup_selection" "kanidm" {
  name         = "kanidm-pvc"
  plan_id      = aws_backup_plan.kanidm.id
  iam_role_arn = aws_iam_role.backup.arn
  resources    = ["arn:aws:ec2:*:*:volume/*"]

  condition {
    string_equals {
      key   = "aws:ResourceTag/kubernetes.io/created-for/pvc/namespace"
      value = "addon-kanidm"
    }
    string_equals {
      key   = "aws:ResourceTag/KubernetesCluster"
      value = "eks-demo"
    }
  }
}
