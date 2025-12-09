resource "hcloud_firewall" "firewalls" {
  for_each = { for firewall in local.firewalls : firewall.name => firewall }

  name = each.value.name

  dynamic "rule" {
    for_each = each.value.rules
    content {
      description = rule.value.description
      direction   = "in"
      port        = lookup(rule.value, "port", null)
      protocol    = rule.value.protocol
      source_ips = lookup(rule.value, "source_ips", [
        "0.0.0.0/0",
        "::/0"
      ])
    }
  }

  apply_to {
    label_selector = each.value.name
  }
}

resource "hcloud_rdns" "reverses" {
  depends_on = [
    hcloud_server.codespace,
    hcloud_server.coolify,
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
    # coolify
    length(hcloud_server.coolify) > 0 ? {
      coolify-ipv4 = {
        ip_address = hcloud_server.coolify[0].ipv4_address
        server_id  = hcloud_server.coolify[0].id
        subdomain  = "coolify"
      }
      coolify-ipv6 = {
        ip_address = hcloud_server.coolify[0].ipv6_address
        server_id  = hcloud_server.coolify[0].id
        subdomain  = "coolify"
      }
    } : {},
  ]...)

  dns_ptr    = "${each.value.subdomain}.${ovh_domain_name.dev.domain_name}"
  ip_address = each.value.ip_address
  server_id  = each.value.server_id
}
