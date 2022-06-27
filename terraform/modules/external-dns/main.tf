/**
* External DNS
* https://github.com/kubernetes-sigs/external-dns
*/

locals {
  external_dns_repository = "https://charts.bitnami.com/bitnami"
  external_dns_namespace  = "external-dns"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}

resource "kubernetes_namespace" "external_dns_namespace" {
  metadata {
    annotations = {
      name = local.external_dns_namespace
    }

    labels = {
      name = local.external_dns_namespace
    }

    name = local.external_dns_namespace
  }
}

resource "helm_release" "external_dns" {
  name          = "external-dns"
  repository    = local.external_dns_repository
  chart         = "external-dns"
  version       = var.external_dns_chart_version
  force_update  = true
  recreate_pods = true
  namespace     = kubernetes_namespace.external_dns_namespace.metadata[0].name
  wait          = false
  values = [templatefile("${path.module}/templates/values.yaml", {
    roleArn       = var.external_dns_role_arn
    domainFilters = jsonencode(var.external_dns_domain_filters)
  })]
}
