module "github_repository_pooling" {
  source = "./github_repository"

  name         = "pooling"
  description  = "Easily dispatch functions (and subfunctions indefinitely) into a shared pool of routines in golang"
  homepage_url = "https://pkg.go.dev/github.com/kilianpaquier/pooling"
  visibility   = "public"

  topics = ["golang", "parallel-computing", "queue-tasks", "recursive-algorithm"]
}

module "github_repository_settings_pooling" {
  depends_on = [module.github_repository_pooling]
  source     = "./github_repository_settings"

  repository = module.github_repository_pooling.name

  default_branch     = "main"
  protected_branches = [{ name = "main" }]

  actions_disabled = true
  labels           = local.labels
}
