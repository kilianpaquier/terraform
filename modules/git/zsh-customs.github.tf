module "github_repository_zsh-customs" {
  source = "./github_repository"

  name        = "zsh-customs"
  description = "Handle multiple ZSH_CUSTOM at once"
  visibility  = "public"

  has_issues = false

  topics = ["zsh", "zsh-plugins"]
}

module "github_repository_settings_zsh-customs" {
  depends_on = [module.github_repository_zsh-customs]
  source     = "./github_repository_settings"

  repository = module.github_repository_zsh-customs.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
