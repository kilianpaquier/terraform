resource "ovh_ip_firewall" "firewalls" {
  depends_on = [ovh_ip_reverse.reverses]
  for_each   = { for name, reverse in ovh_ip_reverse.reverses : trimsuffix(name, "-ipv4") => reverse.ip_reverse if endswith(name, "-ipv4") }

  enabled        = true
  ip             = each.value
  ip_on_firewall = each.value
}

resource "ovh_ip_firewall_rule" "firewalls" {
  depends_on = [ovh_ip_firewall.firewalls]
  for_each = merge([
    # codespace
    contains(keys(ovh_ip_firewall.firewalls), "codespace") ? merge([
      {
        for firewall in local.ovh-firewalls : "codespace-${firewall.name}" => merge(firewall, {
          ip = ovh_ip_firewall.firewalls["codespace"].ip_on_firewall
        })
      },
      {
        for index, firewall in local.firewalls : "codespace-${firewall.name}" => merge(firewall, {
          action   = "permit"
          ip       = ovh_ip_firewall.firewalls["codespace"].ip_on_firewall
          sequence = index + 1 // 0 is reserverd
        }) if contains(local.codespace.labels, firewall.name)
      },
    ]...) : {},
    # public cloud instances
    merge([
      for instance in local.instances : merge(
        {
          for firewall in local.ovh-firewalls : "${instance.name}-${firewall.name}" => merge(firewall, {
            ip = ovh_ip_firewall.firewalls[instance.name].ip_on_firewall
          }) if contains(keys(ovh_ip_firewall.firewalls), instance.name)
        },
        {
          for index, firewall in local.firewalls : "${instance.name}-${firewall.name}" => merge(firewall, {
            action   = "permit"
            ip       = ovh_ip_firewall.firewalls[instance.name].ip_on_firewall
            sequence = index + 1 // 0 is reserverd
          }) if contains(keys(ovh_ip_firewall.firewalls), instance.name) && contains(instance.labels, firewall.name)
        }
      )
    ]...)
  ]...)

  action           = each.value.action
  destination_port = lookup(each.value, "port", null)
  ip               = each.value.ip
  ip_on_firewall   = each.value.ip
  protocol         = each.value.protocol
  sequence         = each.value.sequence
  tcp_option       = lookup(each.value, "tcp_option", null)
}

resource "ovh_ip_reverse" "reverses" {
  depends_on = [
    data.ovh_vps.codespace,
    ovh_cloud_project_instance.d2-2,
    ovh_domain_name.dev,
    ovh_domain_zone_record.records
  ]
  for_each = merge([
    # codespace
    length(data.ovh_vps.codespace) > 0 ? {
      codespace-ipv4 = {
        ip_reverse = ovh_domain_zone_record.records["codespace-ovh-ipv4"].target
        range      = "32"
        subdomain  = "codespace"
      }
      codespace-ipv6 = {
        ip_reverse = ovh_domain_zone_record.records["codespace-ovh-ipv6"].target
        range      = "128"
        subdomain  = "codespace"
      }
    } : {},
    # public cloud instances
    merge([
      for name, instance in ovh_cloud_project_instance.d2-2 : {
        "${name}-ipv4" = {
          ip_reverse = ovh_domain_zone_record.records["${name}-ovh-ipv4"].target
          range      = "32"
          subdomain  = name
        }
        "${name}-ipv6" = {
          ip_reverse = ovh_domain_zone_record.records["${name}-ovh-ipv6"].target
          range      = "128"
          subdomain  = name
        }
      }
    ]...)
  ]...)

  ip         = lookup(each.value, "ip", "${each.value.ip_reverse}/${lookup(each.value, "range", null)}")
  ip_reverse = each.value.ip_reverse
  reverse    = "${each.value.subdomain}.ovh.${ovh_domain_name.dev.domain_name}."
}
