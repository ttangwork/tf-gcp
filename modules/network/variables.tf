# project
variable "project_id" {
  description = "The ID of the project in which to create the network."
  type        = string
}

variable "region" {
  description = "The region in which to create the network."
  type        = string
}
# vpc
variable "vpc_name" {
  description = "The name of the VPC network to create."
  type        = string
}
variable "routing_mode" {
  description = "The network routing mode. Can be either 'REGIONAL' or 'GLOBAL'."
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "Whether to automatically create subnetworks in each region. If true, a subnetwork will be created in each region with the same name as the network."
  type        = bool
  default     = false
}

# subnet
variable "master_cidr" {
  description = "Private /28 CIDR for GKE control plane"
  type        = string
}
variable "gke_nodes_cidr" {
  description = "The CIDR range for the GKE nodes subnet."
  type        = string
}
variable "pods_cidr" {
  description = "The CIDR range for the GKE pods secondary IP range."
  type        = string
}
variable "services_cidr" {
  description = "The CIDR range for the GKE services secondary IP range."
  type        = string
}
variable "management_cidr" {
  description = "The CIDR range for the management subnet."
  type        = string
}
