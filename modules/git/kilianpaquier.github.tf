# resource "github_user_ssh_key" "ssh_key" {
#   for_each = { for k, repo in module.shared.public_keys : k => repo if k == "codespace" }
#   title    = each.key
#   key      = each.value
# }

# see https://github.com/integrations/terraform-provider-github/pull/2366
# resource "github_user_ssh_signing_key" "ssh_signing_key" {
#   for_each = { for k, repo in module.shared.public_keys : k => repo if k == "codespace" }
#   title    = each.key
#   key      = each.value
# }
