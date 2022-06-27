variable "vpa_version_chart" {
  type        = string
  description = "vpa chart version"
  default     = "1.4.0"
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}
