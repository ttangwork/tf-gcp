variable "routing_mode" {
  description = "The network routing mode. Can be either 'REGIONAL' or 'GLOBAL'."
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Whether to automatically create subnetworks in each region. If true, a subnetwork will be created in each region with the same name as the network."
  type        = bool
}

variable "mtu" {
  description = "The network MTU (Maximum Transmission Unit) size in bytes. The default value is 1460 bytes, which is the recommended MTU for Google Cloud VPC networks. You can set this to a different value if you have specific requirements for your network traffic."
  type        = number
}
