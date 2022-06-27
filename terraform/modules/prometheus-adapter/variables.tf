variable "prometheus_adapter_chart_version" {
  type        = string
  description = "Prometheus adapter chart version"
  default     = "3.3.1"
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}

variable "prometheus_namespace" {
  type        = string
  description = "Prometheus namespace"
}
