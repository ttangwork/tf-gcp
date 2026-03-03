# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
  mtu                     = var.mtu
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
