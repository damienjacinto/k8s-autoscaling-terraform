locals {
    tags = {}
    aws_auth_roles = [
        {
            rolearn  = aws_iam_role.eks_worker_node_role.arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:nodes","system:bootstrappers"]
        },
    ]
    aws_auth_users = var.eks_aws_auth_users
    aws_auth_accounts = []
    aws_auth_configmap_data = {
        mapRoles    = yamlencode(local.aws_auth_roles)
        mapUsers    = yamlencode(local.aws_auth_users)
        mapAccounts = yamlencode(local.aws_auth_accounts)
    }
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster.eks_cluster.name
}
