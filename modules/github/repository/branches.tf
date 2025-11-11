resource "github_branch_default" "default" {
  branch     = var.default_branch
  repository = var.repository
  rename     = true
}
