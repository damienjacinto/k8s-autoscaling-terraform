# control plane
resource "aws_security_group" "eks_control_plane" {
  name        = "tf-sg-eks-control-plane"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.eks_vpc_id

  tags = { "Name" = "tf-sg-eks-control-plane" }
}

resource "aws_security_group_rule" "allow_above_1025_tcp_egress_from_control_plane_to_worker_node" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1025
  to_port                  = 65535
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_worker_node.id
  description              = "Allow the cluster control plane to communicate with worker Kubelet and pods"
}

resource "aws_security_group_rule" "allow_https_from_worker_node_to_eks_control_plane_api" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_worker_node.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_https_egress_from_control_plane_to_worker_node" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_worker_node.id
  description              = "Allow the cluster control plane to communicate with pods running extension API servers on port 443"
}

# worker nodes
resource "aws_security_group" "eks_worker_node" {
  name        = "tf-sg-eks-worker-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.eks_vpc_id

  tags = merge({ "Name" = "tf-sg-eks-worker-nodes", "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" })
}

resource "aws_security_group_rule" "allow_all_from_worker_node_to_world" {
  type              = "egress"
  protocol          = "-1"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_worker_node.id
  description       = "Enable all outbound"
}

resource "aws_security_group_rule" "allow_all_from_worker_node_to_worker_node" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker_node.id
  source_security_group_id = aws_security_group.eks_worker_node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_https_from_control_plane_to_worker_nodes" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_node.id
  source_security_group_id = aws_security_group.eks_control_plane.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_above_1025_tcp_from_control_plane_to_worker_node" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_node.id
  source_security_group_id = aws_security_group.eks_control_plane.id
  to_port                  = 65535
  type                     = "ingress"
}