# One-time adoption of the resources that terraform-env-demo demo/4-role created.
# Remove this file after the import is applied.
import {
  to = aws_iam_role.github_ecr_public_pull
  id = "github--argocd-env-addons-ecr-public"
}

import {
  to = aws_iam_role_policy.github_ecr_public_pull
  id = "github--argocd-env-addons-ecr-public:ecr-public-pull-token"
}
