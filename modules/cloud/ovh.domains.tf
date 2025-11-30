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
    hcloud_server.instances,
    ovh_cloud_project_instance.d2-2,
    ovh_domain_name.dev
  ]
  for_each = merge(
    {
      codespace-ipv4 = {
        subdomain = "codespace"
        target    = one([for ip in data.ovh_vps.codespace.ips : ip if strcontains(ip, ".")])
        type      = "A"
      }
      codespace-ipv6 = {
        subdomain = "codespace"
        target    = one([for ip in data.ovh_vps.codespace.ips : ip if strcontains(ip, ":")])
        type      = "AAAA"
      }
      storageshare = {
        subdomain = "storageshare"
        target    = "nx84000.your-storageshare.de."
        type      = "CNAME"
      }
    },
    {
      for name, instance in ovh_cloud_project_instance.d2-2 : "${name}-ipv4" => {
        subdomain = instance.name
        target    = one([for address in instance.addresses : address.ip if address.version == 4])
        type      = "A"
      }
    },
    {
      for name, instance in ovh_cloud_project_instance.d2-2 : "${name}-ipv6" => {
        subdomain = instance.name
        target    = one([for address in instance.addresses : address.ip if address.version == 6])
        type      = "AAAA"
      }
    },
    {
      for name, instance in hcloud_server.instances : "${name}-ipv4" => {
        subdomain = instance.name
        target    = instance.ipv4_address
        type      = "A"
      }
    },
    {
      for name, instance in hcloud_server.instances : "${name}-ipv6" => {
        subdomain = instance.name
        target    = instance.ipv6_address
        type      = "AAAA"
      }
    }
  )

  zone      = ovh_domain_name.dev.domain_name
  subdomain = each.value.subdomain
  fieldtype = each.value.type
  target    = each.value.target
}
