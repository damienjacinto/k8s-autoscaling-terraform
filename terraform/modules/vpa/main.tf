locals {
  repository  = "https://charts.fairwinds.com/stable"
  namespace   = "vpa"
  chart       = "vpa"
  releasename = "vpa"
}

resource "kubernetes_namespace" "vpa" {
  metadata {
    annotations = {
      name = local.namespace
    }
    labels = {
      name     = local.namespace
      provider = "terraform"
    }
    name = local.namespace
  }
}

resource "helm_release" "vpa" {
  name          = local.releasename
  repository    = local.repository
  chart         = local.chart
  version       = var.vpa_version_chart
  force_update  = false
  recreate_pods = true
  namespace     = kubernetes_namespace.vpa.metadata[0].name
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
    clusterName = var.eks_cluster_name
  })]
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}
