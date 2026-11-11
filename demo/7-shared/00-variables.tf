variable "workspace_max_pods" {
  description = "Workspace Pod capacity; keep aligned with argocd-env-apps env/eks-demo.yaml. Each Pod reserves 1 CPU and 2Gi memory."
  type        = number
  default     = 32
  validation {
    condition     = var.workspace_max_pods >= 1 && var.workspace_max_pods <= 128 && floor(var.workspace_max_pods) == var.workspace_max_pods
    error_message = "workspace_max_pods must be an integer between 1 and 128."
  }
}

variable "workspace_ephemeral_storage_gib" {
  description = "Encrypted Auto Mode node disk for Sandbox emptyDirs and the kubelet-managed image cache."
  type        = number
  default     = 160
  validation {
    condition     = var.workspace_ephemeral_storage_gib >= 80 && var.workspace_ephemeral_storage_gib <= 1000 && floor(var.workspace_ephemeral_storage_gib) == var.workspace_ephemeral_storage_gib
    error_message = "workspace_ephemeral_storage_gib must be an integer between 80 and 1000."
  }
}

variable "rovr_sandbox_max_pods" {
  description = "rovr sandbox Pod capacity; keep aligned with rovr.sandbox.max_runs in argocd-env-apps env/eks-demo.yaml. Each Pod reserves 2 CPU and 4Gi memory."
  type        = number
  default     = 6
  validation {
    condition     = var.rovr_sandbox_max_pods >= 1 && var.rovr_sandbox_max_pods <= 60 && floor(var.rovr_sandbox_max_pods) == var.rovr_sandbox_max_pods
    error_message = "rovr_sandbox_max_pods must be an integer between 1 and 60."
  }
}

variable "zones" {
  description = "agent-database NodePool이 노드를 띄울 수 있는 AZ 목록입니다. terraform-env-demo demo/6-eks-node의 baseline_zones와 같게 둡니다."
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}
