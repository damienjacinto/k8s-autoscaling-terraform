variable "external_dns_chart_version" {
  type        = string
  description = "External dns chart version"
  default     = "6.2.4"
}

variable "external_dns_domain_filters" {
  type        = list(string)
  description = "List of domain name to handle with external dns"
  default     = []
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}

variable "external_dns_role_arn" {
  description = "ARN of external role IAM"
  type        = string
}
