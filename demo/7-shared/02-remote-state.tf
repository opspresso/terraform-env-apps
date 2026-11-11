# The cluster of terraform-env-demo demo/5-eks. The associations and node pools belong to it.
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "terraform-workshop-396608815058"
    key    = "backend/demo/eks-demo/terraform.tfstate"
  }
}
