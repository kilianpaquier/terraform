data "tailscale_device" "default" {
  hostname = var.hostname
  wait_for = "10m" # retry until this duration is reached to ensure server has the time to register itself
}

resource "tailscale_device_key" "default" {
  depends_on          = [data.tailscale_device.default]
  device_id           = data.tailscale_device.default.node_id
  key_expiry_disabled = var.key_expiry_disabled
}

resource "tailscale_device_tags" "default" {
  depends_on = [data.tailscale_device.default]
  count      = length(var.tags) > 0 ? 1 : 0

  device_id = data.tailscale_device.default.node_id
  tags      = var.tags
}
