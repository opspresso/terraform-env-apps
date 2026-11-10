variable "region" {
  description = "The Target region."
  type        = string
  default     = "ap-northeast-2"
}

variable "management_account_id" {
  description = "The account of the EKS cluster that runs the Agent Runway Workflows (eks-demo)."
  type        = string
  default     = "396608815058"
}

variable "target_name" {
  description = "The Agent Runway Target name. It is also the second segment of the Variables' SSM path."
  type        = string
  default     = "demo-eb"
}

variable "asg_target_name" {
  description = "The Agent Runway aws-asg Target name in this account."
  type        = string
  default     = "demo-asg"
}

variable "domain" {
  description = "The app domain of the Target. Hosts are <slug>.<domain> and <slug>-<env>.<domain>."
  type        = string
  default     = "apps.rovr.dev"
}

variable "hosted_zone" {
  description = "The public Route53 zone that holds the app hosts."
  type        = string
  default     = "rovr.dev"
}

variable "solution_stack" {
  description = "The Elastic Beanstalk Docker platform of new and updated environments."
  type        = string
  default     = "64bit Amazon Linux 2023 v4.14.1 running Docker"
}

variable "instance_types" {
  description = "Graviton instance types an application.yaml may choose; the first is the default."
  type        = list(string)
  default     = ["t4g.small", "t4g.medium", "m7g.large"]

  validation {
    condition     = length(var.instance_types) > 0 && alltrue([for type in var.instance_types : can(regex("^[a-z][0-9]+g[a-z]*\\.", type))])
    error_message = "Every instance type must be Graviton (arm64): Release images are linux/arm64 unless the Project builds amd64."
  }
}

variable "secrets_key_alias" {
  description = "The KMS key of Agent Runway's SecureString Variables (RUNWAY_KMS_KEY_ID)."
  type        = string
  default     = "alias/agent-runway"
}
