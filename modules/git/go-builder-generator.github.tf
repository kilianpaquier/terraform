module "github_repository_go-builder-generator" {
  source = "./github_repository"

  name        = "go-builder-generator"
  description = "Easily generate builders for golang structs"
  visibility  = "public"

  has_discussions = true

  topics = ["builders", "generator", "golang"]
}

module "github_repository_settings_go-builder-generator" {
  depends_on = [module.github_repository_go-builder-generator]
  source     = "./github_repository_settings"

  repository = module.github_repository_go-builder-generator.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
