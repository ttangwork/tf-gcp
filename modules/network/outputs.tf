output "vpc_id" {
  description = "VPC self link"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "VPC name"
  value       = google_compute_network.main.name
}

output "gke_nodes_subnet_id" {
  description = "GKE nodes subnet self link"
  value       = google_compute_subnetwork.gke_nodes.id
}

output "gke_nodes_subnet_name" {
  description = "GKE nodes subnet name"
  value       = google_compute_subnetwork.gke_nodes.name
}

output "management_subnet_id" {
  description = "Management subnet self link"
  value       = google_compute_subnetwork.management.id
}
