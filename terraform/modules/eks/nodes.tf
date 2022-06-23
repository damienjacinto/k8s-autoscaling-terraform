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
/etc/eks/bootstrap.sh  "${aws_eks_cluster.eks_cluster.id}" --kubelet-extra-args '--max-pods=110'  --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL  --use-max-pods false
USERDATA

}
