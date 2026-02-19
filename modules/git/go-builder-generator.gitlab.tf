module "gitlab_project_go-builder-generator" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "go-builder-generator"

  default_branch   = "main"
  description      = "Easily generate builders for golang structs"
  visibility_level = "public"

  analytics_access_level          = "disabled"
  container_registry_access_level = "disabled"
  environments_access_level       = "disabled"
  feature_flags_access_level      = "disabled"
  infrastructure_access_level     = "disabled"
  model_experiments_access_level  = "disabled"
  model_registry_access_level     = "disabled"
  monitor_access_level            = "disabled"
  pages_access_level              = "disabled"
  requirements_access_level       = "disabled"
  snippets_access_level           = "disabled"
  wiki_access_level               = "disabled"

  branch_name_regex    = local.branch_name_regex
  commit_message_regex = local.commit_message_regex
}

module "gitlab_project_settings_go-builder-generator" {
  depends_on = [
    module.github_repository_go-builder-generator,
    module.gitlab_project_go-builder-generator
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_go-builder-generator.id
  protected_branches = ["main"]

  schedules = [
    {
      active      = false
      cron        = "0 12 * * *"
      description = "Scheduled pipeline for kickr layout updates"
      name        = "kickr"
      ref         = "refs/heads/main"
    }
  ]

  mirror = {
    token = sensitive(data.sops_file.sops["gitlab"].data["github_mirror_token"])
    url   = module.github_repository_go-builder-generator.http_clone_url
  }
}
