resource "aws_wafv2_web_acl" "amplify_waf" {
  name  = "${var.zone}-amplify-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.zone}-amplify-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(var.default_tags, { Domain = var.zone })
}

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

resource "aws_wafv2_web_acl_association" "amplify_waf" {
  resource_arn = aws_amplify_app.zone_app.arn
  web_acl_arn  = aws_wafv2_web_acl.amplify_waf.arn
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

  wait_for_verification = false
}

output "amplify_app_id" {
  value       = aws_amplify_app.zone_app.id
  description = "Amplify App ID for GitHub Actions deployment"
}
