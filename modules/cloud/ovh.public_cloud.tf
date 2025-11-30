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
    ovh_cloud_project.selfhosted,
    ovh_domain_name.dev
  ]
  for_each = tomap({
    # bentopdf = {
    #   file  = "nginx-based.yml"
    #   image = "docker.io/bentopdf/bentopdf:latest"
    # }
    # changedetection = { # FIXME not working yet
    #   file  = "" # see https://github.com/dgtlmoon/changedetection.io/blob/master/docker-compose.yml
    #   image = "ghcr.io/dgtlmoon/changedetection.io:latest"
    # }
    # cyberchef = {
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/gchq/cyberchef:latest"
    # }
    # it-tools = {
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/corentinth/it-tools:latest"
    # }
    # omni-tools = {
    #   file  = "nginx-based.yml"
    #   image = "docker.io/iib0011/omni-tools:latest"
    # }
    # stirling-pdf = {
    #   file  = "stirling-pdf.yml"
    #   image = "docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest-ultra-lite"
    # }
    # vert = {
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/vert-sh/vert:latest"
    # }
  })

  billing_period = "hourly"
  name           = each.key
  region         = "GRA9"
  service_name   = ovh_cloud_project.selfhosted.project_id

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

  user_data = templatefile("${path.module}/cloud-init/${each.value.file}", {
    domain   = ovh_domain_name.dev.domain_name
    image    = each.value.image
    instance = each.key

    debug       = lookup(each.value, "debug", false)
    ssh_port    = data.sops_file.sops["ovh"].data["ssh_port"]
    public_keys = [for key, value in module.shared.public_keys : value]

    ovh_application_key    = data.sops_file.sops["ovh"].data["dns_application_key"]
    ovh_application_secret = data.sops_file.sops["ovh"].data["dns_application_secret"]
    ovh_consumer_key       = data.sops_file.sops["ovh"].data["dns_consumer_key"]
    ovh_endpoint           = local.ovh_endpoint
  })
}
