variable "region" {
  description = "앱 이미지 repository(ECR)가 있는 리전입니다."
  type        = string
  default     = "ap-northeast-2"
}

variable "target_account_ids" {
  description = "Agent Runway eb Target이 있는 다른 계정입니다. 그 계정의 앱 instance 역할이 `projects/*` 이미지를 pull합니다(terraform-env-two `two/8-runway-target`)."
  type        = list(string)
  default     = ["552292899126"]

  validation {
    condition     = alltrue([for id in var.target_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "target_account_ids의 항목은 12자리 AWS 계정 ID여야 합니다."
  }
}

variable "parent_zone" {
  description = "다른 계정 eb Target의 앱 도메인을 위임하는 public Route53 zone입니다."
  type        = string
  default     = "rovr.dev"
}

variable "target_domains" {
  description = "다른 계정 eb Target의 앱 도메인과 그 계정 zone의 name server입니다. 값은 그 zone을 만든 root의 output `name_servers`입니다(terraform-env-two `two/3-domain`)."
  type        = map(list(string))
  default = {
    "two.rovr.dev" = [
      "ns-1534.awsdns-63.org",
      "ns-1710.awsdns-21.co.uk",
      "ns-406.awsdns-50.com",
      "ns-833.awsdns-40.net",
    ]
  }

  validation {
    condition     = alltrue([for domain, servers in var.target_domains : endswith(domain, ".${var.parent_zone}") && length(servers) > 0])
    error_message = "target_domains의 도메인은 parent_zone의 하위 도메인이어야 하고 name server가 하나 이상 있어야 합니다."
  }
}
