# The app domain: a public zone in this account, delegated from the parent zone of the management account. The deploy
# role writes each environment's <host> record here, and the load balancers serve the wildcard certificate. App hosts
# have one label under the domain (<slug>.<domain>, <slug>-<env>.<domain>), so the wildcard covers them all.
resource "aws_route53_zone" "apps" {
  name    = var.domain
  comment = "Agent Runway eb target ${var.target_name}"
}

data "aws_route53_zone" "parent" {
  provider = aws.management

  name         = var.parent_zone
  private_zone = false
}

resource "aws_route53_record" "delegation" {
  provider = aws.management

  zone_id = data.aws_route53_zone.parent.zone_id
  name    = var.domain
  type    = "NS"
  ttl     = 3600
  records = aws_route53_zone.apps.name_servers
}

resource "aws_acm_certificate" "apps" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = { for option in aws_acm_certificate.apps.domain_validation_options : option.domain_name => option }

  zone_id = aws_route53_zone.apps.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 300
  records = [each.value.resource_record_value]
}

# ACM resolves the validation record through the parent zone, so it waits for the delegation.
resource "aws_acm_certificate_validation" "apps" {
  certificate_arn         = aws_acm_certificate.apps.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  depends_on = [aws_route53_record.delegation]
}
