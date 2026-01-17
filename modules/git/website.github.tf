module "github_repository_website" {
  source = "./github_repository"

  name         = "website"
  description  = "Personal portfolio"
  homepage_url = "https://kilianpaquier.dev"
  visibility   = "public"

  has_discussions = true
  has_issues      = false

  topics = ["github-pages", "hugo", "portfolio"]
}

module "github_repository_settings_website" {
  depends_on = [module.github_repository_website]
  source     = "./github_repository_settings"

  repository = module.github_repository_website.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
