module "github_repository_compare" {
  source = "./github_repository"

  description  = "Compare files and directories with Golang internal diff library"
  homepage_url = "https://pkg.go.dev/github.com/kilianpaquier/compare"
  name         = "compare"
  visibility   = "public"

  topics = ["compare-files", "compare-text", "compare-directories", "golang", "golang-library"]
}

module "github_repository_settings_compare" {
  depends_on = [module.github_repository_compare]
  source     = "./github_repository_settings"

  repository = module.github_repository_compare.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
