variable "target_names" {
  description = "The names of the eb targets that run in this account. Each name is the second segment of its Variables' SSM path /agent-runway/<name>/."
  type        = list(string)

  validation {
    condition     = length(var.target_names) > 0 && alltrue([for name in var.target_names : can(regex("^[a-z][a-z0-9-]{1,30}$", name))])
    error_message = "Give one or more eb target names that match ^[a-z][a-z0-9-]{1,30}$."
  }
}

variable "target_step_role_arn" {
  description = "The Pod Identity role of the VM Target Workflow steps (terraform-env-opsp demo/7-eks-shared pod-role--delivery-target). It assumes the deploy role."
  type        = string
}

variable "runway_role_arn" {
  description = "The Pod Identity role of Agent Runway (terraform-env-opsp demo/7-eks-shared pod-role--agent-runway). It assumes the secrets role."
  type        = string
  default     = null

  validation {
    condition     = var.external_id == null || var.runway_role_arn != null
    error_message = "A Target in another account (external_id set) needs runway_role_arn for its secrets role."
  }
}

variable "external_id" {
  description = "The external ID that Agent Runway generated for the environment of this account (account.access.externalId). Null for a Target in Agent Runway's own account: then the deploy role needs no external ID and the module makes no secrets role."
  type        = string
  default     = null

  validation {
    # RE2 allows at most 1000 repetitions, so the length is checked apart.
    condition     = var.external_id == null || (length(var.external_id) >= 2 && length(var.external_id) <= 1224 && can(regex("^[A-Za-z0-9+=,.@:/-]+$", var.external_id)))
    error_message = "external_id must be an STS external ID: 2-1224 characters of A-Z, a-z, 0-9 and +=,.@:/-."
  }
}

variable "domain" {
  description = "The app domain of the Target. Hosts are <slug>.<domain> and <slug>-<env>.<domain>."
  type        = string
}

variable "hosted_zone_id" {
  description = "The public Route53 zone that holds the app hosts."
  type        = string
}

variable "secrets_key_arn" {
  description = "The KMS key of the SecureString Variables of this account's targets."
  type        = string
}

variable "artifact_bucket" {
  description = "The name of the source bundle bucket."
  type        = string
}
