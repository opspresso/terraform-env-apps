resource "aws_iam_role" "this" {
  for_each = local.pod_identities

  name               = format("%s--%s", local.prefix_name, each.key)
  assume_role_policy = data.aws_iam_policy_document.pod_identity.json

  tags = {
    Name = format("%s--%s", local.prefix_name, each.key)
  }
}

resource "aws_iam_policy" "this" {
  for_each = local.pod_identities

  name        = format("%s--%s", local.prefix_name, each.key)
  description = format("%s--%s -- pod identity", local.prefix_name, each.key)
  policy      = file(format("%s/policies/%s.json", path.module, each.key))

  tags = {
    Name = format("%s--%s", local.prefix_name, each.key)
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.pod_identities

  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}
