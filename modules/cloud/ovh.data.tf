data "ovh_me" "myaccount" {}

data "ovh_order_cart" "subsidiary" {
  ovh_subsidiary = data.ovh_me.myaccount.ovh_subsidiary
}

data "ovh_order_cart_product_plan" "vps-1" {
  cart_id        = data.ovh_order_cart.subsidiary.id
  price_capacity = "renew"
  product        = "vps"
  plan_code      = "vps-2025-model1"
}

data "ovh_order_cart_product_plan" "cloud" {
  cart_id        = data.ovh_order_cart.subsidiary.id
  price_capacity = "renew"
  product        = "cloud"
  plan_code      = "project.2018"
}
