variable "region" {
  description = "AWS region of the eks-demo volumes."
  type        = string
  default     = "ap-northeast-2"
}

variable "retention_days" {
  description = "Days AWS Backup keeps each Kanidm volume snapshot."
  type        = number
  default     = 30
}
