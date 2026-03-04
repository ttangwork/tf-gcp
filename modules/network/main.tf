# VPC
resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = var.vpc_name
  routing_mode            = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
}

# Subnets
resource "google_compute_subnetwork" "gke_nodes" {
  project                  = var.project_id
  name                     = "${var.vpc_name}-gke-nodes"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.gke_nodes_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_subnetwork" "management" {
  project       = var.project_id
  name          = "${var.vpc_name}-management"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = var.management_cidr
}

resource "google_compute_subnetwork" "data" {
  project                  = var.project_id
  name                     = "${var.vpc_name}-data"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.data_cidr
  private_ip_google_access = true
}

# Cloud Router and Cloud NAT for outbound internet access from private subnets
resource "google_compute_router" "main" {
  project = var.project_id
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  project                            = var.project_id
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke_nodes.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  project   = var.project_id
  name      = "${var.vpc_name}-allow-internal"
  network   = google_compute_network.main.name
  priority  = 1000
  direction = "INGRESS"

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = [
    var.gke_nodes_cidr,
    var.pods_cidr,
    var.services_cidr,
    var.management_cidr,
    var.data_cidr,
  ]
}

# GKE control plane -> nodes (kubelet, webhooks)
resource "google_compute_firewall" "gke_control_plane_to_nodes" {
  project  = var.project_id
  name     = "${var.vpc_name}-gke-control-plane-to-nodes"
  network  = google_compute_network.main.name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"] # kubelet + API server
  }
  allow {
    protocol = "tcp"
    ports    = ["4443", "8443", "9443"] # admission webhooks
  }

  target_tags   = ["gke-node"]
  source_ranges = [var.master_cidr]
}

# IAP to Bastion VM
resource "google_compute_firewall" "allow_iap_to_bastion" {
  project  = var.project_id
  name     = "${var.vpc_name}-bastion-ssh"
  network  = google_compute_network.main.name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]
}

# Explicit deny-all ingress by default (lowest priority)
resource "google_compute_firewall" "deny_all_ingress" {
  project   = var.project_id
  name      = "${var.vpc_name}-deny-all-ingress"
  network   = google_compute_network.main.name
  priority  = 65534
  direction = "INGRESS"

  deny { protocol = "all" }

  source_ranges = ["0.0.0.0/0"]
}
