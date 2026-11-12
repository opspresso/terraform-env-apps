variable "region" {
  description = "앱 이미지 repository(ECR)가 있는 리전입니다."
  type        = string
  default     = "ap-northeast-2"
}

variable "target_account_ids" {
  description = "Agent Runway eb Target이 있는 다른 계정입니다. 그 계정의 앱 instance 역할이 `projects/*` 이미지를 pull합니다(demo/8-runway-target-two)."
  type        = list(string)
  default     = ["552292899126"]

  validation {
    condition     = alltrue([for id in var.target_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "target_account_ids의 항목은 12자리 AWS 계정 ID여야 합니다."
  }
}
