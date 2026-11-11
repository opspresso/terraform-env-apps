# One-time adoption of the resources that terraform-env-demo demo/4-role and demo/5-eks created.
# Remove this file after the import is applied.
locals {
  import_association_ids = {
    "agent-studio"    = "a-wfigswnzcgos2ath9"
    "agent-runway"    = "a-qap21omnuquuyblba"
    "agent-knowledge" = "a-zwlavzg4cz68uwdrh"
    "mcp-cloudwatch"  = "a-1o0w9ynfgxgbsyhxi"
    "app-delivery"    = "a-tckm7ms2ksofvi72x"
    "delivery-target" = "a-nfc9lt1j3b1stpmkb"
    "gitlab"          = "a-tpj2w9untu2kegevm"
  }
}

import {
  for_each = local.pod_identities
  to       = aws_iam_role.this[each.key]
  id       = format("%s--%s", local.prefix_name, each.key)
}

import {
  for_each = local.pod_identities
  to       = aws_iam_policy.this[each.key]
  id       = format("arn:aws:iam::%s:policy/%s--%s", local.account_id, local.prefix_name, each.key)
}

import {
  for_each = local.pod_identities
  to       = aws_iam_role_policy_attachment.this[each.key]
  id       = format("%s--%s/arn:aws:iam::%s:policy/%s--%s", local.prefix_name, each.key, local.account_id, local.prefix_name, each.key)
}

import {
  for_each = local.import_association_ids
  to       = aws_eks_pod_identity_association.this[each.key]
  id       = format("eks-demo,%s", each.value)
}
