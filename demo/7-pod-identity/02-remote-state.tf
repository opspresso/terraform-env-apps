# The associations bind roles to ServiceAccounts of the terraform-env-demo cluster.
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "terraform-workshop-396608815058"
    key    = "backend/demo/eks-demo/terraform.tfstate"
  }
}
