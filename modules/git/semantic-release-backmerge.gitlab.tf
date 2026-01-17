module "gitlab_project_semantic-release-backmerge" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "semantic-release-backmerge"

  default_branch   = "main"
  description      = "Backmerge feature for semantic-release with automatic PR creation when a conflict is identified. Available for GitHub, GitLab, Bitbucket and Gitea"
  mirror           = "https://github.com/kilianpaquier/semantic-release-backmerge.git"
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

module "gitlab_project_settings_semantic-release-backmerge" {
  depends_on = [
    module.github_repository_semantic-release-backmerge,
    module.gitlab_project_semantic-release-backmerge
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_semantic-release-backmerge.id
  protected_branches = ["main"]

  # schedules = [
  #   {
  #     cron        = "0 12 * * *"
  #     description = "Scheduled pipeline for kickr layout updates"
  #     name        = "kickr"
  #     ref         = "refs/heads/main"
  #   }
  # ]

  # mirror = {
  #   token = sensitive(data.sops_file.sops["gitlab"].data["github_mirror_token"])
  #   url   = module.github_repository_semantic-release-backmerge.http_clone_url
  # }
}
