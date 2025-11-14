resource "gitlab_project_environment" "environments" {
  for_each = { for env in var.environments : env.environment => env }
  project  = var.project

  description         = each.value.description
  name                = each.key
  stop_before_destroy = true
  tier                = each.value.tier
}
