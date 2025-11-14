resource "gitlab_project_variable" "variables" {
  for_each = merge([
    # environment variables
    merge([
      for env in var.environments : {
        for variable in env.variables : "${env.environment}:${variable.key}" => merge(variable, {
          environment_scope = env.environment
          protected         = contains(["production", "staging"], env.tier)
        })
      }
    ]...),
    # global variables
    {
      for variable in var.variables : variable.key => merge(variable, {
        environment_scope = "*"
      })
    }
  ]...)

  project     = var.project
  key         = each.value.key
  description = each.value.description

  environment_scope = each.value.environment_scope
  hidden            = each.value.sensitive
  masked            = each.value.sensitive
  protected         = each.value.protected
  raw               = each.value.raw
  value             = sensitive(each.value.value)
  variable_type     = "env_var"
}
