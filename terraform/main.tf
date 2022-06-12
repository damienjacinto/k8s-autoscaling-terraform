locals {
  cluster_name = "tf-k8s-autoscaling"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"
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
  }
}

module "eks" {
  source     = "./modules/eks"
  eks_cluster_name = "k8s-autoscaling"
  eks_vpc_id = module.vpc.vpc_id
  eks_subnet_k8s_publics_ids =  module.vpc.public_subnets
  eks_subnet_k8s_privates_ids =  module.vpc.private_subnets
  eks_assume_role = var.aws_assume_role
}

module "vpce" {
  source     = "./modules/vpce"
  vpce_vpc_id     = module.vpc.vpc_id
  vpce_vpc_cidr   = module.vpc.vpc_cidr_block
}