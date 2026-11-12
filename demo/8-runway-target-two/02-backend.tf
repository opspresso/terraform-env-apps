terraform {
  required_version = "1.17.1"

  # The state stays with the other roots in the management account; the backend uses the default credentials.
  backend "s3" {
    region       = "ap-northeast-2"
    bucket       = "terraform-workshop-396608815058"
    key          = "backend/demo/runway-target-two/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

provider "aws" {
  region              = var.region
  profile             = var.profile
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = local.tags
  }
}

# The management account, with the default credentials. This root changes only the delegation of the app domain there.
provider "aws" {
  alias               = "management"
  region              = var.region
  allowed_account_ids = [var.management_account_id]

  default_tags {
    tags = local.tags
  }
}
