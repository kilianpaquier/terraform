module "github_repository_dotfiles" {
  source = "./github_repository"

  name        = "dotfiles"
  description = "My dotfiles tests and final configuration"
  visibility  = "public"

  has_issues = false

  topics = ["dotfiles"]
}

module "github_repository_settings_dotfiles" {
  depends_on = [module.github_repository_dotfiles]
  source     = "./github_repository_settings"

  repository = module.github_repository_dotfiles.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
