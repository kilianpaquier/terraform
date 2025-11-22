resource "github_repository_webhook" "gitlab" {
  count      = var.webhook != null ? 1 : 0
  repository = var.repository

  active = true
  events = ["pull_request", "push"]

  configuration {
    content_type = "application/json"
    insecure_ssl = false
    secret       = var.webhook.secret
    url          = var.webhook.url
  }
}

resource "github_actions_repository_permissions" "disabled" {
  count      = var.actions_disabled ? 1 : 0
  repository = var.repository

  enabled = false
}

resource "github_actions_repository_permissions" "enabled" {
  count      = !var.actions_disabled ? 1 : 0
  repository = var.repository

  enabled         = true
  allowed_actions = "all"
}
