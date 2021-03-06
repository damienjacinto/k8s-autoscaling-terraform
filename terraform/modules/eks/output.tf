output "worker_nodes_role_arn" {
  value       = aws_iam_role.eks_worker_node_role.arn
  description = "worker nodes role ARN"
}

# output "min_nodes" {
#   value       = aws_autoscaling_group.eks_worker_node.min_size
#   description = "Minimum number of nodes of the Auto scaling group"
# }

# output "max_nodes" {
#   value       =  aws_autoscaling_group.eks_worker_node.max_size
#   description = "Maximum number of nodes of the Auto scaling group"
# }

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "worker_nodes_security_group" {
  description = "worker nodes security group"
  value       = aws_security_group.eks_worker_node.id
}

output "oidc_issuer" {
  value = {
    arn = aws_iam_openid_connect_provider.eks_cluster.arn
    url = aws_iam_openid_connect_provider.eks_cluster.url
  }
}

output "vpc_id" {
  value = aws_security_group.eks_control_plane.vpc_id
}

# output "worker" {
#   value = aws_autoscaling_group.eks_worker_node.id
# }

output "aws_lb_controller_role_arn" {
  value = aws_iam_role.aws_lb_controller.arn
}

output "karpenter_role_arn" {
  value = aws_iam_role.karpenter_role.arn
}

output "karpenter_launch_template_name" {
  value = aws_launch_template.eks_worker_karpenter_launch_template.name
}

output "worker_nodes_instance_profile" {
  value = aws_iam_instance_profile.eks_worker_node_role.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns_role.arn
}
