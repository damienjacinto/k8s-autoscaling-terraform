/**
* This module will deploy [karpenter](https://github.com/aws/karpenter)
* prerequisite:
* - [eks](https://github.com/FinalCAD/terraform-infrastructure/tree/develop/modules/eks)
* - [OpenID_connect](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html): manage permissions
*
*/

locals {
  karpenter_namespace     = "karpenter"
  karpenter_repository    = "https://charts.karpenter.sh"
  karpenter_chart         = "karpenter"
  release_name            = "karpenter"
}

data "aws_availability_zones" "available" {}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations = {
      name = local.karpenter_namespace
    }
    labels = {
      name     = local.karpenter_namespace
      provider = "terraform"
    }
    name = local.karpenter_namespace
  }
}

resource "helm_release" "karpenter" {
  name          = local.release_name
  repository    = local.karpenter_repository
  chart         = local.karpenter_chart
  version       = var.karpenter_version
  force_update  = false
  recreate_pods = true
  namespace     = kubernetes_namespace.karpenter.metadata.0.name
  wait          = false

  values = [templatefile("${path.module}/templates/values.yaml", {
    defaultInstanceProfile = var.worker_nodes_instance_profile
    clusterEndpoint        = var.cluster_endpoint
    clusterName            = var.eks_cluster_name
    roleArn                = var.karpenter_role_arn
  })]
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = var.eks_cluster_name
}
