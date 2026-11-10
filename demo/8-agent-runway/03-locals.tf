locals {
  account_id = data.aws_caller_identity.current.account_id
  # 4-role이 만든 Pod Identity 역할. 이름 규칙은 4-role의 `pod-role--<policy>`입니다.
  runway_role_arn           = "arn:aws:iam::${local.account_id}:role/pod-role--agent-runway"
  external_secrets_role_arn = "arn:aws:iam::${local.account_id}:role/pod-role--external-secrets"

  # Session tags that EKS Pod Identity adds to every credential; they are transitive.
  pod_identity_tag_keys = ["eks-cluster-arn", "eks-cluster-name", "kubernetes-namespace", "kubernetes-service-account", "kubernetes-pod-name", "kubernetes-pod-uid"]

  tags = {
    Environment = "demo"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-demo/demo/8-agent-runway"
  }
}
