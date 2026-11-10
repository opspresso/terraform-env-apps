locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  # The Pod Identity role of the VM Target Workflow steps (terraform-env-demo demo/4-role `pod-role--delivery-target`).
  target_step_role_arn = "arn:${local.partition}:iam::${var.management_account_id}:role/pod-role--delivery-target"
  # Session tags that EKS Pod Identity adds to every credential; they are transitive.
  pod_identity_tag_keys = ["eks-cluster-arn", "eks-cluster-name", "kubernetes-namespace", "kubernetes-service-account", "kubernetes-pod-name", "kubernetes-pod-uid"]
  # Every stack of this Target is runway-<project>-<environment>; the session tags name the one a session may change.
  stack_name = "runway-$${aws:PrincipalTag/delivery-project}-$${aws:PrincipalTag/delivery-env}"

  tags = {
    Environment = "demo"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-apps/demo/8-runway-target"
  }
}
