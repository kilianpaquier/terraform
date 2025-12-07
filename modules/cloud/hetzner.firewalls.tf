resource "hcloud_firewall" "firewalls" {
  for_each = { for firewall in local.firewalls : firewall.name => firewall }

  name = each.value.name

  rule {
    description = each.value.description
    direction   = "in"
    port        = lookup(each.value, "port", null)
    protocol    = each.value.protocol
    source_ips = lookup(each.value, "source_ips", [
      "0.0.0.0/0",
      "::/0"
    ])
  }

  apply_to {
    label_selector = each.value.name
  }
}

resource "hcloud_rdns" "reverses" {
  depends_on = [
    hcloud_server.codespace,
    hcloud_server.instances,
    ovh_domain_name.dev
  ]
  for_each = merge([
    # codespace
    length(hcloud_server.codespace) > 0 ? {
      codespace-ipv4 = {
        ip_address = hcloud_server.codespace[0].ipv4_address
        server_id  = hcloud_server.codespace[0].id
        subdomain  = "codespace"
      }
      codespace-ipv6 = {
        ip_address = hcloud_server.codespace[0].ipv6_address
        server_id  = hcloud_server.codespace[0].id
        subdomain  = "codespace"
      }
    } : {},
    # instances
    merge([
      for name, instance in hcloud_server.instances : {
        "${name}-ipv4" = {
          ip_address = instance.ipv4_address
          server_id  = instance.id
          subdomain  = name
        }
        "${name}-ipv6" = {
          ip_address = instance.ipv6_address
          server_id  = instance.id
          subdomain  = name
        }
      }
    ]...)
  ]...)

  dns_ptr    = "${each.value.subdomain}.hcloud.${ovh_domain_name.dev.domain_name}"
  ip_address = each.value.ip_address
  server_id  = each.value.server_id
}
