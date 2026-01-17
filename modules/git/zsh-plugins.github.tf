module "github_repository_zsh-plugins" {
  source = "./github_repository"

  name        = "zsh-plugins"
  description = "A bunch of ZSH plugins that also acts as installation plugins to avoid running an installation script"
  visibility  = "public"

  topics = ["zsh-plugin", "zsh-plugins"]
}

module "github_repository_settings_zsh-plugins" {
  depends_on = [module.github_repository_zsh-plugins]
  source     = "./github_repository_settings"

  repository = module.github_repository_zsh-plugins.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
