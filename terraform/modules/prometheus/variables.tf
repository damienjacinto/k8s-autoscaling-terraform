variable "prometheus_chart_version" {
  type        = string
  description = "Prometheus chart version"
  default     = "15.10.1"
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}
