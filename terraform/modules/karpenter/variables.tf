variable "karpenter_version" {
  type    = string
  default = "0.11.1"
}

variable "instances" {
  type        = list(string)
  default     = ["t3.large", "t3.medium", "t3.small", "t3.xlarge", "t3a.large", "t3a.medium", "t3a.xlarge"]
  description = "List of instances that can be provided by karpenter provisionner"
}

variable "capacity_type" {
  type        = list(string)
  default     = ["spot"]
  description = "List of capacity type that can be provided by karpenter provisionner"
}

variable "ttl_seconds_after_empty" {
  type        = string
  default     = 30
  description = "Time in second after empty node are reclaim by karpenter provisionner"
}

variable "ttl_seconds_until_expired" {
  type        = string
  default     = ""
  description = "Time in second after any node are reclaim by karpenter provisionner (empty no reclaim)"
}

variable "max_cpu" {
  type        = string
  default     = "20"
  description = "Maximum vCPU that can be provisionned by karpenter"
}

variable "max_memory" {
  type        = string
  default     = "50Gi"
  description = "Maximum memoryy that can be provisionned by karpenter"
}

variable "eks_cluster_name" {
  description = "ESK cluster name"
  type        = string
}

variable "karpenter_role_arn" {
  description = "karpenter IAM role arn"
  type        = string
}

variable "worker_nodes_instance_profile" {
  description = "woker node instance profile"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}
