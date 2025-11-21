data "cloudflare_zone" "zachtech" {
  filter = {
    name = var.zone
  }
}

resource "cloudflare_dns_record" "zone_a_record" {
  zone_id = data.cloudflare_zone.zachtech.zone_id
  name    = var.zone
  content = aws_amplify_domain_association.zone_domain.certificate_verification_dns_record
  type    = "CNAME"
  ttl     = 60
  proxied = false

  comment = join(",", [for key, value in merge(var.default_tags, { Domain = var.zone }) : "${key}=${value}"])
}

resource "aws_acm_certificate" "zone_cert" {
  provider = aws.us-east-1

  domain_name       = var.zone
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.default_tags, { Domain = var.zone })
}

resource "cloudflare_dns_record" "zone_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.zone_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
    }
  }

  zone_id = data.cloudflare_zone.zachtech.zone_id
  name    = trimsuffix(each.value.name, ".")
  content = trimsuffix(each.value.value, ".")
  type    = "CNAME"
  ttl     = 60
  proxied = false

  comment = join(",", [for key, value in merge(var.default_tags, { Domain = var.zone }) : "${key}=${value}"])
}

resource "aws_acm_certificate_validation" "zone_cert_validation_wait" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.zone_cert.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.zone_cert_validation : record.name]
}