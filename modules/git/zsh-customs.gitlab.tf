module "gitlab_project_zsh-customs" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "zsh-customs"

  default_branch   = "main"
  description      = "Handle multiple ZSH_CUSTOM at once"
  visibility_level = "public"

  analytics_access_level               = "disabled"
  container_registry_access_level      = "disabled"
  environments_access_level            = "disabled"
  feature_flags_access_level           = "disabled"
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

module "gitlab_project_settings_zsh-customs" {
  depends_on = [
    module.github_repository_zsh-customs,
    module.gitlab_project_zsh-customs
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_zsh-customs.id
  protected_branches = ["main"]

  mirror = {
    token = sensitive(data.sops_file.sops["gitlab"].data["github_mirror_token"])
    url   = module.github_repository_zsh-customs.http_clone_url
  }
}
