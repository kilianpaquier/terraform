resource "hcloud_server" "codespace" {
  depends_on = [
    data.cloudinit_config.codespace,
    hcloud_ssh_key.ssh_keys,
    hcloud_placement_group.default
  ]
  count = contains(keys(data.cloudinit_config.codespace), "hcloud") ? 1 : 0

  lifecycle {
    ignore_changes = [ssh_keys]
  }

  name        = "codespace"
  datacenter  = "nbg1-dc3"
  image       = "debian-13"
  server_type = "cx23"

  allow_deprecated_images  = false
  delete_protection        = false
  rebuild_protection       = false
  shutdown_before_deletion = true

  backups            = false
  keep_disk          = true
  labels             = { for label in local.codespace.labels : label => "" }
  placement_group_id = hcloud_placement_group.default.id

  ssh_keys = [for key, value in module.shared.public_keys : key]

  user_data = data.cloudinit_config.codespace["hcloud"].rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "instances" {
  depends_on = [
    data.cloudinit_config.instances,
    hcloud_placement_group.default,
    hcloud_ssh_key.ssh_keys
  ]
  for_each = {
    for instance in local.instances : instance.name => {
      labels    = instance.labels
      user_data = data.cloudinit_config.instances["${instance.name}-hcloud"]
    } if contains(instance.hosts, "hcloud")
  }

  lifecycle {
    ignore_changes = [ssh_keys]
  }

  name        = each.key
  datacenter  = "nbg1-dc3"
  image       = "docker-ce"
  server_type = "cx23"

  allow_deprecated_images  = false
  delete_protection        = false
  rebuild_protection       = false
  shutdown_before_deletion = true

  backups            = false
  keep_disk          = true
  labels             = { for name in each.value.labels : name => "" }
  placement_group_id = hcloud_placement_group.default.id

  ssh_keys = [for key, value in module.shared.public_keys : key]

  user_data = sensitive(each.value.user_data.rendered)

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
