locals {
  launch_template_name = "eks-worker-${aws_eks_cluster.eks_cluster.name}"
  node_group_name      = "critical-node-${aws_eks_cluster.eks_cluster.name}"
}

resource "aws_launch_template" "eks_worker_launch_template" {
  name                                 = local.launch_template_name
  image_id                             = data.aws_ami.eks_worker_node_official_ami.id
  user_data                            = base64encode(local.eks_worker_node_userdata)
  vpc_security_group_ids               = [aws_security_group.eks_worker_node.id]
  instance_type                        = var.eks_worker_node_instance_type

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = merge(local.tags, { Name = local.launch_template_name })
    }
  }

  tags = merge(
    local.tags,
    { Name = local.launch_template_name }
  )
}

resource "aws_eks_node_group" "critical_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
  subnet_ids      = var.eks_subnet_k8s_privates_ids
  launch_template {
    id      = aws_launch_template.eks_worker_launch_template.id
    version = aws_launch_template.eks_worker_launch_template.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = var.eks_max_node_pool
    min_size     = var.eks_min_node_pool
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  tags = merge(
    local.tags,
    { Name = local.node_group_name }
  )
}
