resource "ovh_domain_name" "dev" {
  domain_name = module.shared.domain

  target_spec = {
    dns_configuration = {
      name_servers = [
        {
          name_server = "ns200.anycast.me"
        },
        {
          name_server = "dns200.anycast.me"
        }
      ]
    }
  }
}

resource "ovh_domain_zone_record" "records" {
  depends_on = [
    data.ovh_vps.codespace,
    hcloud_server.codespace,
    hcloud_server.coolify,
    ovh_domain_name.dev
  ]
  for_each = merge(
    # hcloud codespace
    length(hcloud_server.codespace) > 0 ? {
      codespace-ipv4 = {
        subdomain = "codespace"
        target    = hcloud_server.codespace[0].ipv4_address
        type      = "A"
      }
      codespace-ipv6 = {
        subdomain = "codespace"
        target    = hcloud_server.codespace[0].ipv6_address
        type      = "AAAA"
      }
    } : {},
    # ovh codespace
    length(data.ovh_vps.codespace) > 0 ? {
      codespace-ipv4 = {
        subdomain = "codespace"
        target    = one([for ip in data.ovh_vps.codespace[0].ips : ip if strcontains(ip, ".")])
        type      = "A"
      }
      codespace-ipv6 = {
        subdomain = "codespace"
        target    = one([for ip in data.ovh_vps.codespace[0].ips : ip if strcontains(ip, ":")])
        type      = "AAAA"
      }
    } : {},
    # hcloud coolify
    length(hcloud_server.coolify) > 0 ? merge([
      {
        coolify-ipv4 = {
          subdomain = "coolify"
          target    = hcloud_server.coolify[0].ipv4_address
          type      = "A"
        }
        coolify-ipv6 = {
          subdomain = "coolify"
          target    = hcloud_server.coolify[0].ipv6_address
          type      = "AAAA"
        }
        wildcard-ipv4 = {
          subdomain = "*"
          target    = hcloud_server.coolify[0].ipv4_address
          type      = "A"
        }
        wildcard-ipv6 = {
          subdomain = "*"
          target    = hcloud_server.coolify[0].ipv6_address
          type      = "AAAA"
        }
      },
    ]...) : {},
    # ovh coolify
    length(data.ovh_vps.coolify) > 0 ? {
      coolify-ipv4 = {
        subdomain = "coolify"
        target    = one([for ip in data.ovh_vps.coolify[0].ips : ip if strcontains(ip, ".")])
        type      = "A"
      }
      coolify-ipv6 = {
        subdomain = "coolify"
        target    = one([for ip in data.ovh_vps.coolify[0].ips : ip if strcontains(ip, ":")])
        type      = "AAAA"
      }
      wildcard-ipv4 = {
        subdomain = "*"
        target    = one([for ip in data.ovh_vps.coolify[0].ips : ip if strcontains(ip, ".")])
        type      = "A"
      }
      wildcard-ipv6 = {
        subdomain = "*"
        target    = one([for ip in data.ovh_vps.coolify[0].ips : ip if strcontains(ip, ":")])
        type      = "AAAA"
      }
    } : {},
    # static records
    {
      storageshare = {
        subdomain = "storageshare"
        target    = "nx84000.your-storageshare.de."
        type      = "CNAME"
      }
    }
  )

  zone      = ovh_domain_name.dev.domain_name
  subdomain = each.value.subdomain
  fieldtype = each.value.type
  target    = each.value.target
}
