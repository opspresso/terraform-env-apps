locals {
  # The backend and remote state blocks cannot read locals and repeat this region.
  region     = "ap-northeast-2"
  account_id = data.aws_caller_identity.current.account_id

  # Role names are <prefix_name>--<key>. Other roots and services refer to these names
  # (e.g. pod-role--agent-runway, pod-role--delivery-target); changing the prefix replaces every role.
  prefix_name = "pod-role"

  # One role per key, with the inline policy policies/<key>.json, bound to the ServiceAccount below.
  pod_identities = {
    "agent-studio" = {
      namespace       = "agent-studio"
      service_account = "agent-studio"
    }
    # Agent Runway manages tenant variables (SSM), object credentials and tenant Pod Identity.
    "agent-runway" = {
      namespace       = "agent-runway"
      service_account = "agent-runway"
    }
    # Memory and Forge need no AWS data-plane identity. Agent Knowledge stores sources in its own bucket.
    "agent-knowledge" = {
      namespace       = "agent-knowledge"
      service_account = "agent-knowledge"
    }
    "mcp-cloudwatch" = {
      namespace       = "agent-mcps"
      service_account = "mcp-cloudwatch"
    }
    # The Delivery registry step creates projects/* repositories and assumes the per-Project push role.
    "app-delivery" = {
      namespace       = "app-delivery"
      service_account = "delivery-registry"
    }
    # The steps of the VM Target Workflows (argocd-env-projects app-deploy-eb/-asg, app-remove-eb/-asg, image-bake)
    # assume the roles agent-runway-target-deploy and agent-runway-target-bake of the Target account (8-runway-target).
    "delivery-target" = {
      namespace       = "app-delivery"
      service_account = "delivery-target"
    }
    # GitLab (argocd-env-addons charts/gitlab) keeps its objects in the opspresso-gitlab-* buckets (8-gitlab).
    # Every GitLab Pod uses the one ServiceAccount gitlab.
    "gitlab" = {
      namespace       = "addon-gitlab"
      service_account = "gitlab"
    }
  }

  tags = {
    Environment = "demo"
    ManagedBy   = "Terraform"
    Project     = "terraform-env-opsp/demo/7-eks-shared"
  }
}
