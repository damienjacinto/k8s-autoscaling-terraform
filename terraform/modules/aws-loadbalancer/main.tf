locals {
  repository  = "https://aws.github.io/eks-charts"
  namespace   = "kube-system"
  chart       = "aws-load-balancer-controller"
  releasename = "aws-load-balancer-controller"
}

resource "helm_release" "aws_loadbalancer" {
  name          = local.releasename
  repository    = local.repository
  chart         = local.chart
  version       = var.version_chart
  force_update  = false
  recreate_pods = true
  namespace     = local.namespace
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
    clusterName = var.eks_cluster_name
  })]
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.aws_load_balancer_controller_role_arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
  }
}


data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}
