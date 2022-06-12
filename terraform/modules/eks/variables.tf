variable "eks_cluster_name" {
    type = string
    description = "EKS cluster name"
}

variable "eks_cluster_version" {
    type = string
    description = "EKS cluster version"
    default = "1.22"
}

variable "eks_subnet_k8s_publics_ids" {
    type = list(string)
    description = "EKS cluster public subnet"
}

variable "eks_subnet_k8s_privates_ids" {
    type = list(string)
    description = "EKS cluster public subnet"
}

variable "kube_proxy_version" {
    type = string
    description = "EKS cluster kube_proxy version"
    default = "v1.22.6-eksbuild.1"
}

variable "vpc_cni_version" {
    type = string
    description = "EKS cluster vpc-cni version"
    default = "v1.11.0-eksbuild.1"
}

variable "coredns_version" {
    type = string
    description = "EKS cluster core_dns version"
    default = "v1.8.7-eksbuild.1"
}

variable "eks_worker_node_ami_version" {
    type = string
    description = "EKS AMI(provided by Amazon) used for worker nodes"
    default = "*"
}

variable "eks_worker_node_instance_type" {
  type        = string
  default     = "t3a.small"
  description = "Instance type of the worker nodes managed by the autoscaling group"
}

variable "eks_worker_node_max_spot_price" {
  type        = string
  default     = "0.0316"
  description = "Instance type of the worker nodes managed by the autoscaling group"
}

variable "eks_worker_min_nodes" {
  type        = string
  default     = "1"
  description = "Minimum number of nodes of the Auto scaling group"
}

variable "eks_worker_max_nodes" {
  type        = string
  default     = "2"
  description = "Maximum number of nodes of the Auto scaling group"
}

variable "eks_vpc_id" {
  type        = string  
  description = "VPC id for eks cluster"
}

variable "eks_assume_role" {
  description = "The AWS role to use as master"
  type        = string
}