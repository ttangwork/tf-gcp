output "cluster_name" {
  value = try(module.gke[0].cluster_name, "")
}

output "cluster_endpoint" {
  value     = try(module.gke[0].cluster_endpoint, "")
  sensitive = true
}

output "get_credentials_command" {
  description = "Command to get kubeconfig (run from bastion)"
  value       = try("gcloud container clusters get-credentials ${module.gke[0].cluster_name} --region=${var.region} --project=${var.project_id} --internal-ip", "")
}
