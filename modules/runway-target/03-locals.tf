locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.region
  # Session tags that EKS Pod Identity adds to every credential; they are transitive.
  pod_identity_tag_keys = ["eks-cluster-arn", "eks-cluster-name", "kubernetes-namespace", "kubernetes-service-account", "kubernetes-pod-name", "kubernetes-pod-uid"]
  # Every stack of this Target is runway-<project>-<environment>; the session tags name the one a session may change.
  stack_name = "runway-$${aws:PrincipalTag/delivery-project}-$${aws:PrincipalTag/delivery-env}"
  # A Target in another account trusts the management account's roles only with Agent Runway's external ID, so another
  # installation that uses the same role names cannot reach this account.
  external_id_condition = var.external_id == null ? {} : { StringEquals = { "sts:ExternalId" = var.external_id } }
}
