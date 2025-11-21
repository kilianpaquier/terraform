resource "hcloud_ssh_key" "ssh_keys" {
  for_each   = module.shared.public_keys
  name       = each.key
  public_key = each.value
}
