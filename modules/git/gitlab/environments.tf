resource "gitlab_project_environment" "environments" {
  for_each = { for env in var.environments : env.environment => env }
  project  = var.project

  name         = each.key
  description  = each.value.description
  external_url = each.value.external_url

  stop_before_destroy = true
  tier                = each.value.tier
}
