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

resource "ovh_domain_zone_record" "storageshare" {
  depends_on = [ovh_domain_name.dev]

  zone      = module.shared.domain
  subdomain = "storageshare"
  fieldtype = "CNAME"
  target    = "nx84000.your-storageshare.de."
}

resource "ovh_domain_zone_record" "d2-2" {
  depends_on = [
    ovh_domain_name.dev,
    ovh_cloud_project_instance.d2-2
  ]
  for_each = merge(
    {
      for k, instance in ovh_cloud_project_instance.d2-2 : "${k}-ipv4" => {
        name   = instance.name
        type   = "A"
        target = one([for address in instance.addresses : address.ip if address.version == 4])
      }
    },
    {
      for k, instance in ovh_cloud_project_instance.d2-2 : "${k}-ipv6" => {
        name   = instance.name
        type   = "AAAA"
        target = one([for address in instance.addresses : address.ip if address.version == 6])
      }
    }
  )

  zone      = module.shared.domain
  subdomain = each.value.name
  fieldtype = each.value.type
  target    = each.value.target
}
