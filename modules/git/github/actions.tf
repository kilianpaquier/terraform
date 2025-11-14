data "github_actions_public_key" "public_key" {
  count      = anytrue([for secret in var.secrets : secret.encrypted_value == null]) ? 1 : 0
  repository = var.repository
}

data "github_actions_environment_public_key" "public_keys" {
  for_each = toset([
    for env in var.environments : env.environment
    if anytrue([for secret in env.secrets : secret.encrypted_value == null])
  ])

  repository  = var.repository
  environment = each.value
}

data "external" "sodium_secrets" {
  for_each = merge([
    # environments secrets
    merge([
      for env in var.environments : {
        for secret in env.secrets : "${env.environment}:${secret.secret_name}" => {
          sodium_public_key  = data.github_actions_environment_public_key.public_keys[env.environment].key
          sodium_secret_name = coalesce(secret.from, secret.secret_name)
        } if secret.encrypted_value == null
      }
    ]...),
    # repository secrets
    {
      for secret in var.secrets : secret.secret_name => {
        sodium_public_key  = data.github_actions_public_key.public_key[0].key
        sodium_secret_name = coalesce(secret.from, secret.secret_name)
      } if secret.encrypted_value == null
    }
  ]...)

  program     = ["go", "run", "main.go"]
  working_dir = "${path.module}/sodium"

  query = {
    sodium_public_key  = each.value.sodium_public_key
    sodium_secret_name = each.value.sodium_secret_name
  }
}

resource "github_actions_environment_secret" "secrets" {
  depends_on = [github_repository_environment.environments]
  for_each = merge([
    for env in var.environments : {
      for secret in env.secrets : "${env.environment}:${secret.secret_name}" => {
        encrypted_value = secret.encrypted_value != null ? secret.encrypted_value : data.external.sodium_secrets["${env.environment}:${secret.secret_name}"].result.sodium_encrypted_value
        environment     = env.environment
        secret_name     = secret.secret_name
      }
    }
  ]...)

  environment     = each.value.environment
  repository      = var.repository
  secret_name     = each.value.secret_name
  encrypted_value = each.value.encrypted_value
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
  for_each = { for secret in var.secrets : secret.secret_name => secret.encrypted_value != null ? secret.encrypted_value : data.external.sodium_secrets[secret.secret_name].result.sodium_encrypted_value }

  encrypted_value = each.value
  repository      = var.repository
  secret_name     = each.key
}

resource "github_actions_variable" "variables" {
  for_each = { for variable in var.variables : variable.variable_name => variable.value }

  repository    = var.repository
  variable_name = each.key
  value         = each.value
}
