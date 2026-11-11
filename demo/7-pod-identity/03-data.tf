data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "pod_identity" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:TagSession",
      "sts:AssumeRole",
    ]

    # Only EKS Pod Identity of this account can assume the roles.
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
