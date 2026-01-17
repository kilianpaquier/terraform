module "gitlab_project_hugo-primer" {
  source = "./gitlab_project"

  namespace_id = gitlab_group.kilianpaquier.id
  name         = "hugo-primer"

  default_branch   = "main"
  description      = "Extensible Hugo theme based on Primer, the Design System for GitHub"
  visibility_level = "public"

  analytics_access_level          = "disabled"
  container_registry_access_level = "disabled"
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

module "gitlab_project_settings_hugo-primer" {
  depends_on = [
    module.github_repository_hugo-primer,
    gitlab_group_access_token.access_tokens["release"],
    module.gitlab_project_hugo-primer
  ]
  source = "./gitlab_project_settings"

  project            = module.gitlab_project_hugo-primer.id
  protected_branches = ["main"]

  environments = [
    {
      description  = "Website production environment"
      environment  = "production"
      external_url = "https://hugo-primer.netlify.app"
      tier         = "production"
    }
  ]

  mirror = {
    token = sensitive(data.sops_file.sops["gitlab"].data["github_mirror_token"])
    url   = module.github_repository_hugo-primer.http_clone_url
  }

  schedules = [
    {
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
      value       = "30039a6c-ce0b-4884-a570-63dcc7022c8a"
    }
  ]
}
