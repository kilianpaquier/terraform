module "gitlab_project_renovate" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "renovate"

  default_branch   = "main"
  description      = "Renovate repository with shared configurations and sheduled maintainance for this group"
  visibility_level = "public"

  analytics_access_level               = "disabled"
  container_registry_access_level      = "disabled"
  environments_access_level            = "disabled"
  feature_flags_access_level           = "disabled"
  forking_access_level                 = "disabled"
  infrastructure_access_level          = "disabled"
  issues_access_level                  = "disabled"
  model_experiments_access_level       = "disabled"
  model_registry_access_level          = "disabled"
  monitor_access_level                 = "disabled"
  pages_access_level                   = "disabled"
  releases_access_level                = "disabled"
  requirements_access_level            = "disabled"
  security_and_compliance_access_level = "disabled"
  snippets_access_level                = "disabled"
  wiki_access_level                    = "disabled"

  branch_name_regex    = local.branch_name_regex
  commit_message_regex = local.commit_message_regex
}

module "gitlab_project_settings_renovate" {
  depends_on = [
    gitlab_group_access_token.access_tokens["renovate"],
    module.gitlab_project_renovate
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_renovate.id
  protected_branches = ["main"]

  schedules = [
    {
      cron        = "0 12 * * *"
      description = "Scheduled pipeline for kickr layout updates and Renovate maintainance"
      name        = "kickr-renovate"
      ref         = "refs/heads/main"
    }
  ]

  variables = [
    {
      key         = "GITHUB_COM_TOKEN"
      description = "GitHub token to retrieve release notes associated with versions updates"
      protected   = true
      raw         = true
      sensitive   = true
      value       = sensitive(data.sops_file.sops["gitlab"].data["github_com_token"])
    },
    {
      key         = "RENOVATE_TOKEN"
      description = "Renovate token to create branches and pull requests for versions maintainance purposes"
      protected   = true
      raw         = true
      sensitive   = true
      value       = sensitive(gitlab_group_access_token.access_tokens["renovate"].token)
    }
  ]
}
