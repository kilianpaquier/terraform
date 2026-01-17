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

  actions_disabled = false
  labels           = local.labels

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", plaintext_value = data.sops_file.sops["github"].data["kickr_private_key"] }]
    },
    { environment = "release", protected_branches = true },
    {
      environment        = "renovate"
      protected_branches = true
      secrets            = [{ secret_name = "RENOVATE_TOKEN", plaintext_value = data.sops_file.sops["github"].data["renovate_token"] }]
    }
  ]
  secrets = [{ secret_name = "CODECOV_TOKEN", plaintext_value = data.sops_file.sops["gitlab"].data["codecov_token"] }]
}
