resource "ovh_cloud_project" "selfhosted" {
  lifecycle {
    ignore_changes = [ # resource is imported, ignore order details
      ovh_subsidiary,
      plan
    ]
  }

  ovh_subsidiary = data.ovh_order_cart.subsidiary.ovh_subsidiary
  plan {
    duration     = data.ovh_order_cart_product_plan.cloud.selected_price[0].duration
    plan_code    = data.ovh_order_cart_product_plan.cloud.plan_code
    pricing_mode = data.ovh_order_cart_product_plan.cloud.selected_price[0].pricing_mode
  }
}

resource "ovh_cloud_project_ssh_key" "public_keys" {
  depends_on = [ovh_cloud_project.selfhosted]
  for_each   = { for key, value in module.shared.public_keys : key => value }

  public_key   = each.value
  service_name = ovh_cloud_project.selfhosted.project_id
  name         = each.key
}
