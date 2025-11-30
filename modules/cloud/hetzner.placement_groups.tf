resource "hcloud_placement_group" "default" {
  name = "default"
  type = "spread"
}
