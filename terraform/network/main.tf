resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu                     = var.mtu
}
