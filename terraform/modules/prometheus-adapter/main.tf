/**
* prometheus-adapter
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

resource "helm_release" "prometheus-adapter" {
  name          = "prometheus-adapter"
  repository    = local.prometheus_repository
  chart         = "prometheus-adapter"
  version       = var.prometheus_adapter_chart_version
  force_update  = true
  recreate_pods = true
  namespace     = var.prometheus_namespace
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
  })]
}
