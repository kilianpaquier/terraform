resource "ovh_vps" "codespace" {
  lifecycle {
    ignore_changes = [
      # resource is imported, ignore order details
      ovh_subsidiary,
      plan,

      # resource is imported, ignore initial ssh_key since it is already provisioned
      public_ssh_key
    ]
  }

  display_name   = "codespace.vps.ovh.net"
  public_ssh_key = module.shared.public_keys.xtia

  ovh_subsidiary = data.ovh_order_cart.subsidiary.ovh_subsidiary
  plan = [
    {
      duration     = data.ovh_order_cart_product_plan.vps-1.selected_price[0].duration
      plan_code    = data.ovh_order_cart_product_plan.vps-1.plan_code
      pricing_mode = data.ovh_order_cart_product_plan.vps-1.selected_price[0].pricing_mode

      configuration = [
        {
          label = "vps_datacenter"
          value = "GRA6"
        },
        {
          label = "vps_os"
          value = "Debian 12"
        }
      ]
    }
  ]
}

data "ovh_vps" "codespace" {
  depends_on   = [ovh_vps.codespace]
  service_name = ovh_vps.codespace.service_name
}
