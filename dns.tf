data "cloudflare_zone" "zachtech" {
  filter = {
    name = var.zone
  }
}

resource "cloudflare_dns_record" "zone_a_record" {
  zone_id = data.cloudflare_zone.zachtech.zone_id
  name    = var.zone
  content = "${aws_amplify_branch.main.branch_name}.${aws_amplify_app.zone_app.default_domain}"
  type    = "CNAME"
  ttl     = 60
  proxied = false

  comment = join(",", [for key, value in merge(var.default_tags, { Domain = var.zone }) : "${key}=${value}"])
}

resource "cloudflare_dns_record" "amplify_cert_validation" {
  for_each = {
    for sub in aws_amplify_domain_association.zone_domain.sub_domain : sub.prefix => sub
  }

  zone_id = data.cloudflare_zone.zachtech.zone_id
  name    = each.value.dns_record.name
  content = each.value.dns_record.value
  type    = each.value.dns_record.type
  ttl     = 60
  proxied = false

  comment = join(",", [for key, value in merge(var.default_tags, { Domain = var.zone, Purpose = "amplify-cert-validation" }) : "${key}=${value}"])
}
