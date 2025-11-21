resource "aws_amplify_app" "zone_app" {
  name = var.zone

  enable_branch_auto_build    = false
  enable_auto_branch_creation = false

  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }

  tags = merge(var.default_tags, { Domain = var.zone })
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.zone_app.id
  branch_name = var.branch_name

  enable_auto_build = false

  tags = merge(var.default_tags, { Domain = var.zone })
}

resource "aws_amplify_domain_association" "zone_domain" {
  app_id      = aws_amplify_app.zone_app.id
  domain_name = var.zone

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  depends_on = [aws_acm_certificate_validation.zone_cert_validation_wait]
}

output "amplify_app_id" {
  value       = aws_amplify_app.zone_app.id
  description = "Amplify App ID for GitHub Actions deployment"
}
