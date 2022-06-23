variable "version_chart" {
  type        = string
  description = "Metrics server chart version"
}

variable "aws_assume_role" {
  description = "The AWS role to use"
  type        = string
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}
