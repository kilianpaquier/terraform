data "tailscale_device" "default" {
  hostname = var.hostname
}

resource "tailscale_device_key" "default" {
  device_id           = data.tailscale_device.default.node_id
  key_expiry_disabled = var.key_expiry_disabled
}

resource "tailscale_device_tags" "default" {
  device_id = data.tailscale_device.default.node_id
  tags      = var.tags
}
