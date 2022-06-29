locals {
  cluster_name = "k8s-autoscaling"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.2.0"
  name                 = "main"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "karpenter.sh/discovery"                      = local.cluster_name
  }
}

module "dns" {
  source    = "./modules/dns"
  zone_name = var.aws_zone_name
}

module "eks" {
  source                      = "./modules/eks"
  eks_cluster_name            = local.cluster_name
  eks_vpc_id                  = module.vpc.vpc_id
  eks_subnet_k8s_publics_ids  = module.vpc.public_subnets
  eks_subnet_k8s_privates_ids = module.vpc.private_subnets
  eks_assume_role             = var.aws_assume_role
  eks_aws_auth_users = [
    {
      userarn  = var.aws_iam_arn
      username = "damien"
      groups   = ["system:nodes", "system:bootstrappers"]
    },
  ]
}

module "vpce" {
  source        = "./modules/vpce"
  vpce_vpc_id   = module.vpc.vpc_id
  vpce_vpc_cidr = module.vpc.vpc_cidr_block
}

module "metrics_server" {
  source           = "./modules/metrics-server"
  eks_cluster_name = module.eks.eks_cluster_name
  aws_assume_role  = var.aws_assume_role
  version_chart    = "3.8.2"
}

module "aws_laodbalancer" {
  source                                = "./modules/aws-loadbalancer"
  eks_cluster_name                      = module.eks.eks_cluster_name
  aws_assume_role                       = var.aws_assume_role
  version_chart                         = "1.4.1"
  aws_load_balancer_controller_role_arn = module.eks.aws_lb_controller_role_arn
}

module "extenal_dns" {
  source                      = "./modules/external-dns"
  eks_cluster_name            = module.eks.eks_cluster_name
  external_dns_domain_filters = split(",", module.dns.zone_dns_name)
  external_dns_role_arn       = module.eks.external_dns_role_arn
}

module "prometheus" {
  source                      = "./modules/prometheus"
  eks_cluster_name            = module.eks.eks_cluster_name
}

module "prometheus-adapter" {
  source                      = "./modules/prometheus-adapter"
  eks_cluster_name            = module.eks.eks_cluster_name
  prometheus_namespace        = module.prometheus.namespace
}

module "karpenter" {
  source                        = "./modules/karpenter"
  eks_cluster_name              = module.eks.eks_cluster_name
  worker_nodes_instance_profile = module.eks.worker_nodes_instance_profile
  cluster_endpoint              = module.eks.eks_cluster_endpoint
  karpenter_role_arn            = module.eks.karpenter_role_arn
}

module "vpa" {
  source                        = "./modules/vpa"
  eks_cluster_name              = module.eks.eks_cluster_name
}

module "locust" {
  source                        = "./modules/locust"
  eks_cluster_name              = module.eks.eks_cluster_name
}
