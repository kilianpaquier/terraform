module "github_repository_semantic-release-backmerge" {
  source = "./github_repository"

  name         = "semantic-release-backmerge"
  description  = "Backmerge feature for semantic-release with automatic PR creation when a conflict is identified. Available for GitHub, GitLab, Bitbucket and Gitea"
  homepage_url = "https://npmjs.com/package/@kilianpaquier/semantic-release-backmerge"
  visibility   = "public"

  topics = ["backmerge", "semantic-release-plugin"]
}

module "github_repository_settings_semantic-release-backmerge" {
  depends_on = [module.github_repository_semantic-release-backmerge]
  source     = "./github_repository_settings"

  repository = module.github_repository_semantic-release-backmerge.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
