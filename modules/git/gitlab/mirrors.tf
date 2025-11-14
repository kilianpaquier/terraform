resource "gitlab_project_integration_github" "github" {
  count   = var.mirror != null ? 1 : 0
  project = var.project

  token          = var.mirror.token
  repository_url = var.mirror.url
}

resource "gitlab_project_mirror" "github" {
  count   = var.mirror != null ? 1 : 0
  project = var.project

  enabled                 = true
  only_protected_branches = true
  url                     = replace(var.mirror.url, "https://", "https://mirror:${var.mirror.token}@")
}
