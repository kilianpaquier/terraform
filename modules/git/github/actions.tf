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
