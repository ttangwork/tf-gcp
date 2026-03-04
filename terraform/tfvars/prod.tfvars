# project
project_id = "project-f53962c2-b852-4294-a0f"
region     = "us-central1"

# vpc
vpc_name                = "prod"
routing_mode            = "REGIONAL"
auto_create_subnetworks = false

# subnet
master_cidr     = "172.16.0.0/28"
gke_nodes_cidr  = "10.0.0.0/20"
pods_cidr       = "10.1.0.0/16"
services_cidr   = "10.2.0.0/20"
management_cidr = "10.0.16.0/24"
data_cidr       = "10.0.17.0/24"
