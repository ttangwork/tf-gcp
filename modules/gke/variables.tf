# project
variable "project_id" {
  description = "The ID of the project in which to create the network."
  type        = string
}

variable "region" {
  description = "The region in which to create the network."
  type        = string
}

# network
variable "vpc_id" {
  description = "The ID of the VPC network to use for the GKE cluster."
  type        = string
}

variable "gke_nodes_subnet_id" {
  description = "The ID of the GKE nodes subnet."
  type        = string
}

variable "management_subnet_id" {
  description = "The ID of the management subnet"
  type        = string
}

variable "master_cidr" {
  description = "The CIDR block for the GKE master endpoint."
  type        = string
}

variable "management_cidr" {
  description = "The CIDR block for management subnet"
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

# bastion vm
variable "bastion_machine_type" {
  description = "The machine type of the bastion VM."
  type        = string
  default     = "e2-micro"
}

variable "bastion_zone" {
  description = "The zone in which to create the bastion VM."
  type        = string
  default     = "us-central1-a"
}
