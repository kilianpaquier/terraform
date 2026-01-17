module "github_repository_hugo-primer" {
  source = "./github_repository"

  name         = "hugo-primer"
  description  = "Extensible Hugo theme based on Primer, the Design System for GitHub"
  homepage_url = "https://hugo-primer.netlify.app"
  visibility   = "public"

  has_discussions = true

  topics = ["hugo", "hugo-module", "hugo-site", "hugo-theme"]
}

module "github_repository_settings_hugo-primer" {
  depends_on = [module.github_repository_hugo-primer]
  source     = "./github_repository_settings"

  repository = module.github_repository_hugo-primer.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
