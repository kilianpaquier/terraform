module "github_repository_gitlab-storage-cleaner" {
  source = "./github_repository"

  name        = "gitlab-storage-cleaner"
  description = "Easily clean gitlab maintained repositories storage (jobs artifacts only) with a simple command"
  visibility  = "public"

  topics = ["artifacts", "cleaner", "gitlab-ci", "golang"]
}

module "github_repository_settings_gitlab-storage-cleaner" {
  depends_on = [module.github_repository_gitlab-storage-cleaner]
  source     = "./github_repository_settings"

  repository = module.github_repository_gitlab-storage-cleaner.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
