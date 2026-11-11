# An association lives as long as its cluster: a new cluster gets new associations from this root.
resource "aws_eks_pod_identity_association" "this" {
  for_each = local.pod_identities

  cluster_name    = data.terraform_remote_state.eks.outputs.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.this[each.key].arn
}
