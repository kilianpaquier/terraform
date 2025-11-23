resource "gitlab_project_integration_github" "github" {
  count   = var.mirror != null ? 1 : 0
  project = var.project

  token          = var.mirror.token
  repository_url = var.mirror.url
}

resource "gitlab_project_mirror" "github" {
  count   = var.mirror != null ? 1 : 0
  project = var.project

  auth_method             = "password"
  enabled                 = true
  keep_divergent_refs     = false
  only_protected_branches = true
  url                     = "https://mirror:${var.mirror.token}@${trimprefix(var.mirror.url, "https://")}"
}
