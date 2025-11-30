resource "ovh_ip_firewall" "firewalls" {
  depends_on = [ovh_ip_reverse.reverses]
  for_each   = { for name, reverse in ovh_ip_reverse.reverses : trimsuffix(name, "-ipv4") => reverse.ip_reverse if endswith(name, "-ipv4") }

  enabled        = true
  ip             = each.value
  ip_on_firewall = each.value
}

resource "ovh_ip_firewall_rule" "baserules" {
  depends_on = [ovh_ip_firewall.firewalls]
  for_each = merge([
    for name, firewall in ovh_ip_firewall.firewalls : {
      "${name}-tcp" = { # allow TCP outgoing
        action     = "permit"
        ip         = firewall.ip_on_firewall
        protocol   = "tcp"
        sequence   = 0
        tcp_option = "established"
      }
      "${name}-dns" = { # allow DNS check
        action           = "permit"
        destination_port = 53
        ip               = firewall.ip_on_firewall
        protocol         = "udp"
        sequence         = 4
      }
      "${name}-ping" = { # allow ping
        action   = "permit"
        ip       = firewall.ip_on_firewall
        protocol = "icmp"
        sequence = 5
      }
      "${name}-denyall" = { # close all TCP incoming and outgoing
        action   = "deny"
        ip       = firewall.ip_on_firewall
        protocol = "tcp"
        sequence = 19
      }
    }
  ]...)

  action           = each.value.action
  destination_port = lookup(each.value, "destination_port", null)
  ip               = each.value.ip
  ip_on_firewall   = each.value.ip
  protocol         = each.value.protocol
  sequence         = each.value.sequence
  tcp_option       = lookup(each.value, "tcp_option", null)
}

resource "ovh_ip_firewall_rule" "allowlist" {
  depends_on = [ovh_ip_firewall.firewalls]
  for_each = merge([
    # codespace
    {
      codespace = { # allow SSH incoming
        action           = "permit"
        destination_port = data.sops_file.sops["ovh"].data["ssh_port"]
        ip               = ovh_ip_firewall.firewalls["codespace"].ip_on_firewall
        protocol         = "tcp"
        sequence         = 1
      }
    },
    # public cloud instances
    merge([
      for name, instance in ovh_cloud_project_instance.d2-2 : {
        for index, port in ["80", "443"] : "${name}-${port}" => { # allow HTTP/S incoming
          action           = "permit"
          destination_port = port
          fragments        = true
          ip               = ovh_ip_firewall.firewalls[name].ip_on_firewall
          protocol         = "tcp"
          sequence         = index + 1 // 0 is reserved to TCP out
        }
      }
    ]...)
  ]...)

  action           = each.value.action
  destination_port = lookup(each.value, "destination_port", null)
  fragments        = lookup(each.value, "fragments", null)
  ip               = each.value.ip
  ip_on_firewall   = each.value.ip
  protocol         = each.value.protocol
  sequence         = each.value.sequence
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
    {
      codespace-ipv4 = {
        ip_reverse = ovh_domain_zone_record.records["codespace-ipv4"].target
        range      = "32"
        subdomain  = "codespace"
      }
      codespace-ipv6 = {
        ip_reverse = ovh_domain_zone_record.records["codespace-ipv6"].target
        range      = "128"
        subdomain  = "codespace"
      }
    },
    # public cloud instances
    merge([
      for name, instance in ovh_cloud_project_instance.d2-2 : {
        "${name}-ipv4" = {
          ip_reverse = ovh_domain_zone_record.records["${name}-ipv4"].target
          range      = "32"
          subdomain  = name
        }
        "${name}-ipv6" = {
          ip_reverse = ovh_domain_zone_record.records["${name}-ipv6"].target
          range      = "128"
          subdomain  = name
        }
      }
    ]...)
  ]...)

  ip         = lookup(each.value, "ip", "${each.value.ip_reverse}/${lookup(each.value, "range", null)}")
  ip_reverse = each.value.ip_reverse
  reverse    = "${each.value.subdomain}.${ovh_domain_name.dev.domain_name}."
}
