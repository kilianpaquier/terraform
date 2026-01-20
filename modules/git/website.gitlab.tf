module "gitlab_project_website" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "website"

  default_branch   = "main"
  description      = "Personal portfolio"
  visibility_level = "public"

  analytics_access_level          = "disabled"
  container_registry_access_level = "disabled"
  feature_flags_access_level      = "disabled"
  forking_access_level            = "disabled"
  infrastructure_access_level     = "disabled"
  issues_access_level             = "disabled"
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

module "gitlab_project_settings_website" {
  depends_on = [
    module.github_repository_website,
    gitlab_group_access_token.access_tokens["release"],
    module.gitlab_project_website
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_website.id
  protected_branches = ["main"]

  environments = [
    {
      description  = "Website production environment"
      environment  = "production"
      external_url = "https://${module.shared.domain}"
      tier         = "production"
    }
  ]

  mirror = {
    token = sensitive(data.sops_file.sops["gitlab"].data["github_mirror_token"])
    url   = module.github_repository_website.http_clone_url
  }

  schedules = [
    {
      active      = false
      cron        = "0 12 * * *"
      description = "Scheduled pipeline for kickr layout updates"
      name        = "kickr"
      ref         = "refs/heads/main"
    }
  ]

  variables = [
    {
      key         = "NETLIFY_AUTH_TOKEN"
      description = "Netlify token for deployments"
      raw         = true
      sensitive   = true
      value       = sensitive(data.sops_file.sops["gitlab"].data["netlify_auth_token"])
    },
    {
      key         = "NETLIFY_SITE_ID"
      description = "Netlify site ID associated for this website"
      raw         = true
      sensitive   = true
      value       = "a2abcddd-4ac5-431b-9d2c-11e391b8ec8c"
    }
  ]
}
