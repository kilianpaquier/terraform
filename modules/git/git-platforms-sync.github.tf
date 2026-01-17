module "github_repository_git-platforms-sync" {
  source = "./github_repository"

  name        = "git-platforms-sync"
  description = "Synchronize your whole repositories on multiple platforms, issues, pull requests, releases, wiki between multiple Git platforms (GitHub, GitLab, etc.)"
  visibility  = "public"

  has_discussions = true

  topics = ["git-sync", "golang", "synchronization"]
}

module "github_repository_settings_git-platforms-sync" {
  depends_on = [module.github_repository_git-platforms-sync]
  source     = "./github_repository_settings"

  repository = module.github_repository_git-platforms-sync.name

  default_branch     = "beta"
  protected_branches = [{ name = "beta" }]

  actions_disabled = true
  labels           = local.labels
}
