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
