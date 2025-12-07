data "cloudinit_config" "codespace" {
  for_each = {
    for host in local.codespace.hosts : host => merge(local.codespace, {
      host = host
    })
  }

  base64_encode = false
  gzip          = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"

    content = templatefile("${path.module}/cloud-init/${each.value.userdata}", {
      ssh_port    = data.sops_file.sops[each.value.host].data["ssh_port"]
      public_keys = [for key, value in module.shared.public_keys : value]
    })
  }
}

data "cloudinit_config" "instances" {
  depends_on = [ovh_domain_name.dev]
  for_each = merge([
    for instance in local.instances : {
      for host in instance.hosts : "${instance.name}-${host}" => merge(instance, {
        host = host
      })
    }
  ]...)

  base64_encode = false
  gzip          = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"

    content = templatefile("${path.module}/cloud-init/${each.value.userdata}", {
      domain    = ovh_domain_name.dev.domain_name
      image     = each.value.image
      instance  = each.value.name
      subdomain = "${each.value.name}.${each.value.host}"

      debug       = contains(each.value.labels, "ssh")
      ssh_port    = data.sops_file.sops[each.value.host].data["ssh_port"]
      public_keys = [for key, value in module.shared.public_keys : value]

      http_port = lookup(each.value, "port", 80)

      ovh_application_key    = data.sops_file.sops["ovh"].data["dns_application_key"]
      ovh_application_secret = data.sops_file.sops["ovh"].data["dns_application_secret"]
      ovh_consumer_key       = data.sops_file.sops["ovh"].data["dns_consumer_key"]
      ovh_endpoint           = local.ovh_endpoint
    })
  }
}
