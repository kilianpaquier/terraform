data "cloudinit_config" "codespace" {
  for_each = { for host in local.codespace.hosts : host => local.codespace }

  base64_encode = false
  gzip          = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"

    content = templatefile("${path.module}/cloud-init/${each.value.userdata}", {
      ssh_port    = data.sops_file.sops["base"].data["ssh_port"]
      public_keys = [for key, value in module.shared.public_keys : value]
    })
  }
}

data "cloudinit_config" "coolify" {
  depends_on = [ovh_domain_name.dev]
  for_each   = { for host in local.coolify.hosts : host => local.coolify }

  base64_encode = false
  gzip          = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"

    content = templatefile("${path.module}/cloud-init/${each.value.userdata}", {
      domain    = ovh_domain_name.dev.domain_name
      subdomain = "coolify"

      email    = data.sops_file.sops["base"].data["coolify_email"]
      username = data.sops_file.sops["base"].data["coolify_username"]
      password = data.sops_file.sops["base"].data["coolify_password"]

      ssh_port    = data.sops_file.sops["base"].data["ssh_port"]
      public_keys = [for key, value in module.shared.public_keys : value]
    })
  }
}
