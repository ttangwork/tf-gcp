# APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "artifactregistry.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "binaryauthorization.googleapis.com",
    "networkservices.googleapis.com", # required for Gateway API
    "trafficdirector.googleapis.com", # required for Gateway API
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# network
module "network" {
  source = "../../modules/network"

  project_id      = var.project_id
  vpc_name        = var.vpc_name
  region          = var.region
  gke_nodes_cidr  = var.gke_nodes_cidr
  pods_cidr       = var.pods_cidr
  services_cidr   = var.services_cidr
  management_cidr = var.management_cidr
  data_cidr       = var.data_cidr
  master_cidr     = var.master_cidr

  depends_on = [google_project_service.apis]
}

# gke cluster
module "gke" {
  source = "../../modules/gke"

  project_id           = var.project_id
  region               = var.region
  cluster_name         = var.cluster_name
  vpc_id               = module.network.vpc_id
  gke_nodes_subnet_id  = module.network.gke_nodes_subnet_id
  management_subnet_id = module.network.management_subnet_id
  master_cidr          = var.master_cidr
  management_cidr      = var.management_cidr
  release_channel      = var.release_channel
  node_machine_type    = var.node_machine_type
  node_disk_size_gb    = var.node_disk_size_gb
  node_disk_type       = var.node_disk_type
  min_node_count       = var.min_node_count
  max_node_count       = var.max_node_count
  enable_gateway_api   = var.enable_gateway_api
}
