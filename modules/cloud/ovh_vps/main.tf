#####################################################
#
# VPS
#
#####################################################

resource "ovh_vps" "default" {
  lifecycle {
    ignore_changes = [image_id, public_ssh_key]
  }

  display_name   = "${var.server_name}.vps.ovh.net"
  image_id       = var.image_id
  public_ssh_key = var.public_key

  ovh_subsidiary = var.ovh_subsidiary
  plan = var.plan != null ? [
    {
      duration     = var.plan.duration
      plan_code    = var.plan.plan_code
      pricing_mode = var.plan.pricing_mode

      configuration = [
        {
          label = "vps_datacenter"
          value = var.plan.datacenter
        },
        {
          label = "vps_os"
          value = var.plan.os
        }
      ]
    }
  ] : []
}

data "ovh_vps" "default" {
  depends_on   = [ovh_vps.default]
  service_name = ovh_vps.default.service_name
}

#####################################################
#
# DNS Records
#
#####################################################

resource "ovh_domain_zone_record" "default" {
  depends_on = [data.ovh_vps.default]
  for_each = merge([
    for record in var.dns_records : {
      "${record.subdomain}.${record.domain}-ipv4" = merge(record, {
        target = local.ipv4
        type   = "A"
      })
      "${record.subdomain}.${record.domain}-ipv6" = merge(record, {
        target = local.ipv6
        type   = "AAAA"
      })
    }
  ]...)

  zone      = each.value.domain
  subdomain = each.value.subdomain
  fieldtype = each.value.type
  target    = each.value.target
}

#####################################################
#
# Firewalls
#
#####################################################

resource "ovh_ip_firewall" "default" {
  depends_on = [data.ovh_vps.default]

  enabled        = length(var.firewalls) > 0
  ip             = local.ipv4
  ip_on_firewall = local.ipv4
}

resource "ovh_ip_firewall_rule" "default" {
  depends_on = [ovh_ip_firewall.default]
  for_each = {
    for index, firewall in var.firewalls : "${firewall.name}-${firewall.sequence}" => merge(firewall, {
      ip = ovh_ip_firewall.default.ip_on_firewall
    })
  }

  action           = each.value.action
  destination_port = sensitive(each.value.port)
  ip               = each.value.ip
  ip_on_firewall   = each.value.ip
  protocol         = each.value.protocol
  sequence         = each.value.sequence
  tcp_option       = each.value.tcp_option
}

resource "ovh_ip_reverse" "default" {
  depends_on = [data.ovh_vps.default]
  for_each = length(var.dns_records) > 0 ? {
    ipv4 = {
      ip_reverse = local.ipv4
      range      = "32"
      reverse    = "${var.dns_records[0].subdomain}.${var.dns_records[0].domain}."
    }
    ipv6 = {
      ip_reverse = local.ipv6
      range      = "128"
      reverse    = "${var.dns_records[0].subdomain}.${var.dns_records[0].domain}."
    }
  } : {}

  ip         = "${each.value.ip_reverse}/${each.value.range}"
  ip_reverse = each.value.ip_reverse
  reverse    = each.value.reverse
}

#####################################################
#
# Cloud Init
#
#####################################################

resource "terraform_data" "cloudinit" {
  depends_on = [data.ovh_vps.default]
  count      = var.cloudinit != null ? 1 : 0

  connection {
    host        = local.ipv4
    port        = 22
    private_key = data.sops_file.sops[0].data[var.cloudinit.sops_private_key]
    type        = "ssh"
    user        = var.cloudinit.user

    timeout = "5m"
  }

  provisioner "file" {
    content     = local.userdata
    destination = "/tmp/cloudinit.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/cloudinit.sh", "/tmp/cloudinit.sh > /tmp/cloudinit.log 2>&1", "rm /tmp/cloudinit.sh"]
  }
}
