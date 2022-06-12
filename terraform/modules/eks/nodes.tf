data "aws_ami" "eks_worker_node_official_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_cluster_version}-v${var.eks_worker_node_ami_version}"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  cluster_ca               = element(aws_eks_cluster.eks_cluster.certificate_authority.*.data, 0)
  eks_worker_node_userdata = <<USERDATA
#!/bin/bash
set -ex
set -o xtrace
# Inject imageGCHighThresholdPercent value unless it has already been set.
if ! grep -q imageGCHighThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sed -i '/"apiVersion*/a \ \ "imageGCHighThresholdPercent": 70,' /etc/kubernetes/kubelet/kubelet-config.json
fi
# Inject imageGCLowThresholdPercent value unless it has already been set.
if ! grep -q imageGCLowThresholdPercent /etc/kubernetes/kubelet/kubelet-config.json;
then
    sed -i '/"imageGCHigh*/a \ \ "imageGCLowThresholdPercent": 50,' /etc/kubernetes/kubelet/kubelet-config.json
fi
B64_CLUSTER_CA="${local.cluster_ca}"
API_SERVER_URL="${aws_eks_cluster.eks_cluster.endpoint}"
/etc/eks/bootstrap.sh  "${aws_eks_cluster.eks_cluster.id}" --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image="${data.aws_ami.eks_worker_node_official_ami.id}",eks.amazonaws.com/nodegroup="${var.eks_cluster_name}-worker-node"' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL
USERDATA

}

resource "aws_launch_configuration" "eks_worker_node" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.eks_worker_node_role.name
  image_id                    = data.aws_ami.eks_worker_node_official_ami.id
  instance_type               = var.eks_worker_node_instance_type
  name_prefix                 = var.eks_cluster_name
  security_groups             = [aws_security_group.eks_worker_node.id]
  user_data_base64            = base64encode(local.eks_worker_node_userdata)  
  spot_price                  = var.eks_worker_node_max_spot_price

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_worker_node" {
  launch_configuration = aws_launch_configuration.eks_worker_node.id
  max_size             = var.eks_worker_max_nodes
  min_size             = var.eks_worker_min_nodes
  name                 = "${var.eks_cluster_name}-worker-nodes"
  vpc_zone_identifier  = var.eks_subnet_k8s_privates_ids
  termination_policies = ["OldestInstance"]
  
  enabled_metrics = []

  tag {
    key                 = "Name"
    value               = "${var.eks_cluster_name}-worker-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}