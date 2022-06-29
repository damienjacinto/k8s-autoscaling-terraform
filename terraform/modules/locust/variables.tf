variable "locust_version" {
  type    = string
  default = "0.27.0"
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}
