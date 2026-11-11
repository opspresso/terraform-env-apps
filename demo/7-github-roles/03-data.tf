data "aws_caller_identity" "current" {}

# terraform-env-demo demo/4-role owns the account's GitHub Actions OIDC provider.
data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}
