/**
* prometheus
* https://prometheus-community.github.io/helm-charts
*/

locals {
  prometheus_repository = "https://prometheus-community.github.io/helm-charts"
  prometheus_namespace  = "prometheus"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}

resource "kubernetes_namespace" "prometheus_namespace" {
  metadata {
    annotations = {
      name = local.prometheus_namespace
    }

    labels = {
      name = local.prometheus_namespace
    }

    name = local.prometheus_namespace
  }
}

resource "helm_release" "prometheus" {
  name          = "prometheus"
  repository    = local.prometheus_repository
  chart         = "prometheus"
  version       = var.prometheus_chart_version
  force_update  = true
  recreate_pods = true
  namespace     = kubernetes_namespace.prometheus_namespace.metadata[0].name
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
  })]
}
