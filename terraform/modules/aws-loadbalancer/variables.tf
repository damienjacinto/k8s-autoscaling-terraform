variable "version_chart" {
  type        = string
  description = "aws loadbalancer chart version"
}

variable "aws_assume_role" {
  description = "The AWS role to use"
  type        = string
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}

variable "aws_load_balancer_controller_role_arn" {
  description = "Arn role for aws load balancer"
  type        = string
}
