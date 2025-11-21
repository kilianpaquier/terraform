resource "gitlab_project" "terraform" {
  namespace_id = gitlab_group.kilianpaquier.id
  name         = "terraform"

  default_branch   = "main"
  description      = "My terraform resources (GitHub, GitLab, cloud instances)"
  visibility_level = "public"

  archive_on_destroy      = true
  keep_latest_artifact    = true
  merge_pipelines_enabled = false
  merge_trains_enabled    = false
  packages_enabled        = false
  public_jobs             = false

  analytics_access_level               = "disabled"
  builds_access_level                  = "enabled"
  container_registry_access_level      = "disabled"
  environments_access_level            = "enabled"
  feature_flags_access_level           = "disabled"
  forking_access_level                 = "disabled"
  infrastructure_access_level          = "enabled"
  issues_access_level                  = "disabled"
  merge_requests_access_level          = "enabled"
  model_experiments_access_level       = "disabled"
  model_registry_access_level          = "disabled"
  monitor_access_level                 = "disabled"
  pages_access_level                   = "disabled"
  releases_access_level                = "disabled"
  repository_access_level              = "enabled"
  requirements_access_level            = "disabled"
  security_and_compliance_access_level = "enabled"
  snippets_access_level                = "disabled"
  wiki_access_level                    = "disabled"

  allow_merge_on_skipped_pipeline                  = true
  auto_cancel_pending_pipelines                    = "enabled"
  autoclose_referenced_issues                      = true
  merge_method                                     = "ff"
  only_allow_merge_if_all_discussions_are_resolved = true
  only_allow_merge_if_pipeline_succeeds            = true
  pre_receive_secret_detection_enabled             = true
  printing_merge_request_link_enabled              = true
  remove_source_branch_after_merge                 = true
  squash_option                                    = "never"
  suggestion_commit_message                        = "chore(review): apply suggestion"

  build_git_strategy                          = "fetch"
  build_timeout                               = 900
  ci_delete_pipelines_in_seconds              = 1296000 # 15d
  ci_forward_deployment_enabled               = true
  ci_forward_deployment_rollback_allowed      = true
  ci_pipeline_variables_minimum_override_role = "maintainer"
  ci_push_repository_for_job_token_allowed    = false
  ci_restrict_pipeline_cancellation_role      = "developer"
  ci_separated_caches                         = true

  resolve_outdated_diff_discussions = false
}

module "gitlab_terraform" {
  depends_on = [
    github_repository.terraform,
    gitlab_group_service_account_access_token.access_tokens["terraform"],
    gitlab_group_variable.variables["CODECOV_TOKEN"],
    # gitlab_group_variable.variables["GITHUB_MIRROR_TOKEN"],
    gitlab_project.terraform
  ]
  source  = "./gitlab"
  project = gitlab_project.terraform.id

  environments = [
    {
      environment = "production"
      description = "Terraform production environment (state separation)"
      tier        = "production"

      variables = [
        # GitHub
        {
          key         = "TF_VAR_github_terraform_token"
          description = "Terraform GitHub token to apply resources"
          sensitive   = true
          raw         = true
          value       = sensitive(var.github_terraform_token)
        },

        # GitLab
        {
          key         = "TF_VAR_codecov_token"
          description = gitlab_group_variable.variables["CODECOV_TOKEN"].description
          sensitive   = false
          raw         = false
          value       = "$${CODECOV_TOKEN}"
        },
        {
          key         = "TF_VAR_github_com_token"
          description = "GitHub token to retrieve release notes associated with versions updates"
          raw         = true
          sensitive   = true
          value       = sensitive(var.github_com_token)
        },
        # {
        #   key         = "TF_VAR_github_mirror_token"
        #   description = gitlab_group_variable.variables["GITHUB_MIRROR_TOKEN"].description
        #   sensitive   = false
        #   raw         = false
        #   value       = "$${GITHUB_MIRROR_TOKEN}"
        # },
        {
          key         = "TF_VAR_github_mirror_token"
          description = "Mirroring GitHub token to push repositories updates onto"
          sensitive   = true
          raw         = true
          value       = sensitive(var.github_mirror_token)
        },
        {
          key         = "TF_VAR_gitlab_terraform_token"
          description = "Terraform GitLab token to apply resources"
          sensitive   = true
          raw         = true
          value       = sensitive(gitlab_group_service_account_access_token.access_tokens["terraform"].token)
        },
        {
          key         = "TF_VAR_kickr_private_key"
          description = "Private Kickr App SSH key to commit with signature on GitHub (for kickr auto layout)"
          sensitive   = true
          raw         = true
          value       = sensitive(var.kickr_private_key)
        },
        {
          key         = "TF_VAR_netlify_auth_token"
          description = "Netlify token needed for static website deployed on that platform"
          sensitive   = true
          raw         = true
          value       = sensitive(var.netlify_auth_token)
        },
        {
          key         = "TF_VAR_renovate_token"
          description = "Renovate token needed for versions maintainance in this group"
          sensitive   = true
          raw         = true
          value       = sensitive(var.renovate_token)
        },

        # Hetzner
        {
          key         = "TF_VAR_hcloud_token"
          description = "Terraform Hetzner token to apply resources"
          sensitive   = true
          raw         = true
          value       = sensitive(var.hcloud_token)
        },
        {
          key         = "TF_VAR_ssh_port"
          description = "Private SSH port instead of well-known 22"
          sensitive   = true
          raw         = true
          value       = sensitive(var.ssh_port)
        }
      ]
    }
  ]

  mirror = {
    token = sensitive(var.github_mirror_token)
    url   = github_repository.terraform.http_clone_url
  }
}
