# project
variable "project_id" {
  description = "The ID of the project in which to create the network."
  type        = string
}

variable "region" {
  description = "The region in which to create the network."
  type        = string
}

# deploy options
variable "deploy_network" {
  description = "Whether to deploy the network resources."
  type        = bool
  default     = false
}

variable "deploy_gke" {
  description = "Whether to deploy the GKE cluster."
  type        = bool
  default     = false
}

# vpc
variable "vpc_name" {
  description = "The name of the VPC network to create."
  type        = string
}
variable "routing_mode" {
  description = "The network routing mode. Can be either 'REGIONAL' or 'GLOBAL'."
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Whether to automatically create subnetworks in each region. If true, a subnetwork will be created in each region with the same name as the network."
  type        = bool
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
variable "data_cidr" {
  description = "The CIDR range for the data subnet."
  type        = string
}

# cluster
variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "enable_gateway_api" {
  description = "Whether to enable Gateway API for the cluster."
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "The release channel to which the cluster belongs. Can be either 'RAPID', 'REGULAR', 'STABLE', or 'NONE'."
  type        = string
  default     = "REGULAR"
}

variable "enable_binary_authorization" {
  description = "Whether to enable Binary Authorization for the cluster."
  type        = bool
  default     = false
}

# node pool
variable "min_node_count" {
  description = "The minimum number of nodes in the node pool."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "The maximum number of nodes in the node pool."
  type        = number
  default     = 10
}

variable "node_machine_type" {
  description = "The machine type of the nodes in the node pool."
  type        = string
  default     = "e2-medium"
}

variable "node_disk_type" {
  description = "The disk type of the nodes in the node pool."
  type        = string
  default     = "pd-standard"
}

variable "node_disk_size_gb" {
  description = "The disk size of the nodes in the node pool."
  type        = number
  default     = 100
}

variable "node_pool_spot" {
  description = "Whether to use spot nodes in the node pool."
  type        = bool
  default     = false
}
