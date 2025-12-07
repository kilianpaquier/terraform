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

resource "ovh_cloud_project_instance" "d2-2" {
  depends_on = [
    data.cloudinit_config.instances,
    ovh_cloud_project.selfhosted,
    ovh_domain_name.dev
  ]
  for_each = {
    for instance in local.instances : instance.name => {
      user_data = data.cloudinit_config.instances["${instance.name}-ovh"]
    } if contains(instance.hosts, "ovh")
  }

  billing_period = "hourly"
  name           = each.key
  region         = "GRA9"
  service_name   = ovh_cloud_project.selfhosted.project_id
  user_data      = sensitive(each.value.user_data.rendered)

  ssh_key {
    name = "xtia"
  }

  boot_from {
    image_id = "b3c48553-9aba-41ee-be4f-9dcdc65a647d" # https://eu.api.ovh.com/console/?section=%2Fcloud&branch=v1#get-/cloud/project/-serviceName-/image
  }

  flavor {
    flavor_id = "fbb7940b-4268-437c-85f8-8c27fcef0dcd" # https://eu.api.ovh.com/console/?section=%2Fcloud&branch=v1#get-/cloud/project/-serviceName-/flavor
  }

  network {
    public = true
  }
}
