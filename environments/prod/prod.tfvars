# project
project_id = "project-f53962c2-b852-4294-a0f"
region     = "us-central1"

# vpc
vpc_name = "prod"

# subnet
master_cidr     = "172.16.0.0/28"
gke_nodes_cidr  = "10.0.0.0/20"
pods_cidr       = "10.1.0.0/16"
services_cidr   = "10.2.0.0/20"
management_cidr = "10.0.16.0/24"

# gke cluster
cluster_name                = "prod-cluster"
enable_gateway_api          = true
release_channel             = "REGULAR"
enable_binary_authorization = false

# node pool
min_node_count    = 0
max_node_count    = 3
node_machine_type = "e2-standard-2"
node_disk_type    = "pd-standard"
node_disk_size_gb = 100
node_pool_spot    = true
