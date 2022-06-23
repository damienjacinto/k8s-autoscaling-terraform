locals {
  repository  = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace   = "kube-system"
  chart       = "metrics-server"
  releasename = "metrics-server"
}

resource "helm_release" "metrics_sever" {
  name          = local.releasename
  repository    = local.repository
  chart         = local.chart
  version       = var.version_chart
  force_update  = false
  recreate_pods = true
  namespace     = local.namespace
  wait          = false
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}
