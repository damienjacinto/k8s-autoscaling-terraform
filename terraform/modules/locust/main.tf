/**
* This module will deploy [locust](https://charts.deliveryhero.io)
*/

locals {
  locust_namespace     = "locust"
  locust_repository    = "https://charts.deliveryhero.io"
  locust_chart         = "locust"
  release_name         = "locust"
}

resource "kubernetes_namespace" "locust" {
  metadata {
    annotations = {
      name = local.locust_namespace
    }
    labels = {
      name     = local.locust_namespace
      provider = "terraform"
    }
    name = local.locust_namespace
  }
}

resource "kubernetes_config_map" "locustfile" {
  metadata {
    name = "loadtest-locustfile"
    namespace = kubernetes_namespace.locust.metadata.0.name
  }

  data = {
    "locustfile.py" = "${file("${path.module}/templates/locustfile.py")}"
  }
}

resource "helm_release" "locust" {
  depends_on = [
    kubernetes_config_map.locustfile
  ]
  name          = local.release_name
  repository    = local.locust_repository
  chart         = local.locust_chart
  version       = var.locust_version
  force_update  = false
  recreate_pods = true
  namespace     = kubernetes_namespace.locust.metadata.0.name
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
  })]
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}
