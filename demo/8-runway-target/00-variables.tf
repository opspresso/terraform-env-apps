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
  description = "The name of the eb target of the Agent Runway environments in this account. It is also the second segment of the Variables' SSM path."
  type        = string
  default     = "demo-eb"
}

variable "amd64_target_name" {
  description = "A second eb target name that an environment of this account may use. Instances read its Variables' SSM path too."
  type        = string
  default     = "demo-eb-amd64"
}

variable "amd64_instance_types" {
  description = "The amd64 instance types of the size tiers small, medium and large, in that order."
  type        = list(string)
  default     = ["t3.small", "t3.medium", "m7i.large"]

  validation {
    condition     = length(var.amd64_instance_types) == 3
    error_message = "Give three amd64 instance types, one per size tier."
  }
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
  description = "The Graviton (arm64) instance types of the size tiers small, medium and large, in that order."
  type        = list(string)
  default     = ["t4g.small", "t4g.medium", "m7g.large"]

  validation {
    condition     = length(var.instance_types) == 3 && alltrue([for type in var.instance_types : can(regex("^[a-z][0-9]+g[a-z]*\\.", type))])
    error_message = "Give three Graviton (arm64) instance types, one per size tier."
  }
}

variable "secrets_key_alias" {
  description = "The KMS key of Agent Runway's SecureString Variables (RUNWAY_KMS_KEY_ID)."
  type        = string
  default     = "alias/agent-runway"
}
