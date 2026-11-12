# 다른 계정 eb Target의 앱 도메인 위임입니다. 하위 zone은 Target 계정에 있고(terraform-env-two `two/3-domain`), 이 계정의
# zone에는 그 zone의 name server를 가리키는 NS 레코드만 둡니다. Target의 deploy role은 하위 zone의 레코드만 바꾸므로 이 zone에는
# 닿지 않습니다. name server는 하위 zone이 있는 동안 바뀌지 않습니다.
data "aws_route53_zone" "parent" {
  name         = var.parent_zone
  private_zone = false
}

resource "aws_route53_record" "target_domain" {
  for_each = var.target_domains

  zone_id = data.aws_route53_zone.parent.zone_id
  name    = each.key
  type    = "NS"
  ttl     = 3600
  records = each.value
}
