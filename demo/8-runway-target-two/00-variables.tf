variable "region" {
  description = "The Target region."
  type        = string
  default     = "ap-northeast-2"
}

variable "account_id" {
  description = "The Target account (nalbam-two). The provider refuses credentials of any other account."
  type        = string
  default     = "552292899126"
}

variable "profile" {
  description = "The local AWS CLI profile (AWS SSO) of the Target account."
  type        = string
  default     = "nalbam-two"
}

variable "management_account_id" {
  description = "The account of Agent Runway and the EKS cluster that runs its Workflows (eks-demo). It owns the parent zone and the image registry."
  type        = string
  default     = "396608815058"
}

variable "runway_external_id" {
  description = "account.access.externalId of the Agent Runway environment of this account (Agent Runway console 관리 > 환경 > stg). Agent Runway generates it; keep it out of Git."
  type        = string
  nullable    = false

  validation {
    # RE2 allows at most 1000 repetitions, so the length is checked apart.
    condition     = length(var.runway_external_id) >= 2 && length(var.runway_external_id) <= 1224 && can(regex("^[A-Za-z0-9+=,.@:/-]+$", var.runway_external_id))
    error_message = "runway_external_id must be an STS external ID: 2-1224 characters of A-Z, a-z, 0-9 and +=,.@:/-."
  }
}

variable "target_name" {
  description = "The name of the eb target of the Agent Runway environment in this account. It is also the second segment of the Variables' SSM path."
  type        = string
  default     = "two-eb-amd64"
}

variable "domain" {
  description = "The app domain of the Target and the name of its public zone. Hosts are <slug>.<domain> and <slug>-<env>.<domain>."
  type        = string
  default     = "two.rovr.dev"
}

variable "parent_zone" {
  description = "The public Route53 zone of the management account that delegates the app domain."
  type        = string
  default     = "rovr.dev"
}

variable "vpc_cidr" {
  description = "The CIDR block of the Target VPC. It does not overlap the eks-demo VPC (10.10.0.0/16)."
  type        = string
  default     = "10.20.0.0/16"
}

variable "az_subnets" {
  description = "Subnet CIDR blocks by availability zone letter. Load balancers use the public subnets; instances use the private subnets, which reach the internet through one NAT gateway."
  type = map(object({
    public  = string
    private = string
  }))
  default = {
    a = { public = "10.20.0.0/20", private = "10.20.64.0/20" }
    c = { public = "10.20.16.0/20", private = "10.20.80.0/20" }
  }

  validation {
    condition     = length(var.az_subnets) >= 2
    error_message = "An application load balancer needs subnets in two or more availability zones."
  }
}

variable "nat_az" {
  description = "The availability zone letter of the single NAT gateway."
  type        = string
  default     = "a"

  validation {
    condition     = contains(keys(var.az_subnets), var.nat_az)
    error_message = "nat_az must be a key of az_subnets."
  }
}

variable "solution_stack" {
  description = "The Elastic Beanstalk Docker platform of new and updated environments."
  type        = string
  default     = "64bit Amazon Linux 2023 v4.14.1 running Docker"
}

variable "amd64_instance_types" {
  description = "The amd64 instance types of the size tiers small, medium and large, in that order."
  type        = list(string)
  default     = ["t3.small", "t3.medium", "m7i.large"]

  validation {
    condition     = length(var.amd64_instance_types) == 3 && alltrue([for type in var.amd64_instance_types : !can(regex("^[a-z][0-9]+g[a-z]*\\.", type))])
    error_message = "Give three amd64 (not Graviton) instance types, one per size tier."
  }
}
