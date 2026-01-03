resource "github_actions_environment_secret" "secrets" {
  depends_on = [github_repository_environment.environments]
  for_each = merge([
    for env in var.environments : {
      for secret in env.secrets : "${env.environment}:${secret.secret_name}" => {
        encrypted_value = secret.encrypted_value
        environment     = env.environment
        secret_name     = secret.secret_name
        plaintext_value = secret.plaintext_value
      }
    }
  ]...)

  environment = each.value.environment
  repository  = var.repository
  secret_name = each.value.secret_name

  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value
}

resource "github_actions_environment_variable" "variables" {
  depends_on = [github_repository_environment.environments]
  for_each = merge([
    for env in var.environments : {
      for variable in env.variables : "${env.environment}:${variable.variable_name}" => {
        environment   = env.environment
        value         = variable.value
        variable_name = variable.variable_name
      }
    }
  ]...)

  environment   = each.value.environment
  repository    = var.repository
  value         = each.value.value
  variable_name = each.value.variable_name
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

resource "github_actions_secret" "secrets" {
  for_each = {
    for secret in var.secrets : secret.secret_name => {
      encrypted_value = secret.encrypted_value
      plaintext_value = secret.plaintext_value
    }
  }

  repository  = var.repository
  secret_name = each.key

  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value
}

resource "github_actions_variable" "variables" {
  for_each = { for variable in var.variables : variable.variable_name => variable.value }

  repository    = var.repository
  variable_name = each.key
  value         = each.value
}

resource "github_branch_default" "default" {
  branch     = var.default_branch
  repository = var.repository
  rename     = true
}

resource "github_issue_labels" "labels" {
  repository = var.repository

  dynamic "label" {
    for_each = { for label in var.labels : label.name => label }
    content {
      color       = trimprefix(label.value.color, "#")
      description = label.value.description
      name        = label.key
    }
  }
}

resource "github_repository_environment" "environments" {
  for_each = { for env in var.environments : env.environment => env }

  environment = each.value.environment
  repository  = var.repository

  can_admins_bypass = false

  dynamic "deployment_branch_policy" {
    for_each = each.value.protected_branches || each.value.custom_branch_policies ? [each.value] : []
    content {
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
      protected_branches     = deployment_branch_policy.value.protected_branches
    }
  }
}

resource "github_repository_ruleset" "tags" {
  name       = "tags"
  repository = var.repository

  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    deletion = true
    update   = true
  }
}

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
