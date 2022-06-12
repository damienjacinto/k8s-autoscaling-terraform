resource "aws_eks_cluster" "eks_cluster" {

  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_service_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_control_plane.id]
    subnet_ids         = concat(var.eks_subnet_k8s_publics_ids, var.eks_subnet_k8s_privates_ids)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_service_role_amazoneks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_role_amazoneks_service_policy,
  ]
  
  tags = merge({ "Name" = "EKS cluster" }, local.tags)
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_version
  resolve_conflicts = "OVERWRITE"
  tags = merge(
    local.tags,
    {
      "eks_addon" = "kube-proxy"
    }
  )
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "coredns"
  addon_version     = var.coredns_version
  resolve_conflicts = "OVERWRITE"
  tags = merge(
    local.tags,
    {
      "eks_addon" = "coredns"
    }
  )
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  resolve_conflicts        = "OVERWRITE"
  tags = merge(
    local.tags,
    {
      "eks_addon" = "vpc-cni"
    }
  )
}

data "tls_certificate" "tls" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}