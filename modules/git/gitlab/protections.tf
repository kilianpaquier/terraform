resource "gitlab_branch_protection" "protections" {
  for_each = var.protected_branches

  project = var.project
  branch  = each.value

  allow_force_push             = false
  code_owner_approval_required = true

  merge_access_level     = "maintainer"
  push_access_level      = "maintainer"
  unprotect_access_level = "maintainer"
}
