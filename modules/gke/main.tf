# Service account for GKE nodes
resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-nodes-sa"
  display_name = "GKE Node Pool SA - ${var.cluster_name}"
}

resource "google_project_iam_member" "gke_nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Cluster
resource "google_container_cluster" "main" {
  project                  = var.project_id
  name                     = var.cluster_name
  location                 = var.region
  initial_node_count       = 1
  remove_default_node_pool = true
  networking_mode          = "VPC_NATIVE"
  datapath_provider        = "ADVANCED_DATAPATH"

  network    = var.vpc_id
  subnetwork = var.gke_nodes_subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_cidr
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.management_cidr
      display_name = "management-subnet"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network_policy {
    enabled  = false
    provider = "PROVIDER_UNSPECIFIED"
  }

  gateway_api_config {
    channel = var.enable_gateway_api ? "CHANNEL_STANDARD" : "CHANNEL_DISABLED"
  }

  release_channel {
    channel = var.release_channel
  }

  enable_legacy_abac = false

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false # required for Gateway API
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true # required for PersistentVolumes
    }
  }

  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [initial_node_count]
  }
}

# Node pool
resource "google_container_node_pool" "main_node_pool" {
  project  = var.project_id
  name     = "${var.cluster_name}-main-pool"
  location = var.region
  cluster  = google_container_cluster.main.id

  autoscaling {
    min_node_count  = var.min_node_count
    max_node_count  = var.max_node_count
    location_policy = "BALANCED"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.node_machine_type
    disk_type       = var.node_disk_type
    disk_size_gb    = var.node_disk_size_gb
    spot            = var.node_pool_spot
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    image_type = "COS_CONTAINERD"
    tags       = ["gke-node"]
    labels = {
      cluster = var.cluster_name
      pool    = "main"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  lifecycle {
    ignore_changes = [node_config[0].resource_labels]
  }
}

# Bastion VM
resource "google_service_account" "bastion" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-bastion-sa"
  display_name = "Bastion VM SA - ${var.cluster_name}"
}

resource "google_project_iam_member" "bastion_cluster_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_compute_instance" "bastion" {
  project      = var.project_id
  name         = "${var.cluster_name}-bastion"
  machine_type = var.bastion_machine_type
  zone         = var.bastion_zone

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.management_subnet_id
    # access_config {} # no public IP
  }

  scheduling {
    provisioning_model = "SPOT"
    automatic_restart  = false
    on_host_maintenance = "TERMINATE"  # required for spot
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = ["bastion"]

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
}

