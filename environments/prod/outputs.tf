output "cluster_name" {
  value = module.gke[0].cluster_name
}

output "cluster_endpoint" {
  value     = module.gke[0].cluster_endpoint
  sensitive = true
}

output "get_credentials_command" {
  description = "Command to get kubeconfig (run from bastion)"
  value       = "gcloud container clusters get-credentials ${module.gke[0].cluster_name} --region=${var.region} --project=${var.project_id} --internal-ip"
}
