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
    hcloud_server.instances,
    ovh_cloud_project_instance.d2-2,
    ovh_domain_name.dev
  ]
  for_each = merge(
    # hcloud codespace
    length(hcloud_server.codespace) > 0 ? {
      codespace-hcloud-ipv4 = {
        subdomain = "codespace.hcloud"
        target    = hcloud_server.codespace[0].ipv4_address
        type      = "A"
      }
      codespace-hcloud-ipv6 = {
        subdomain = "codespace.hcloud"
        target    = hcloud_server.codespace[0].ipv6_address
        type      = "AAAA"
      }
    } : {},
    # ovh codespace
    length(data.ovh_vps.codespace) > 0 ? {
      codespace-ovh-ipv4 = {
        subdomain = "codespace.ovh"
        target    = one([for ip in data.ovh_vps.codespace[0].ips : ip if strcontains(ip, ".")])
        type      = "A"
      }
      codespace-ovh-ipv6 = {
        subdomain = "codespace.ovh"
        target    = one([for ip in data.ovh_vps.codespace[0].ips : ip if strcontains(ip, ":")])
        type      = "AAAA"
      }
    } : {},
    # hcloud instances
    {
      for name, instance in hcloud_server.instances : "${name}-hcloud-ipv4" => {
        subdomain = "${instance.name}.hcloud"
        target    = instance.ipv4_address
        type      = "A"
      }
    },
    {
      for name, instance in hcloud_server.instances : "${name}-hcloud-ipv6" => {
        subdomain = "${instance.name}.hcloud"
        target    = instance.ipv6_address
        type      = "AAAA"
      }
    },
    # ovh instances
    {
      for name, instance in ovh_cloud_project_instance.d2-2 : "${name}-ovh-ipv4" => {
        subdomain = "${instance.name}.ovh"
        target    = one([for address in instance.addresses : address.ip if address.version == 4])
        type      = "A"
      }
    },
    {
      for name, instance in ovh_cloud_project_instance.d2-2 : "${name}-ovh-ipv6" => {
        subdomain = "${instance.name}.ovh"
        target    = one([for address in instance.addresses : address.ip if address.version == 6])
        type      = "AAAA"
      }
    },
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
