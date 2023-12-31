terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster_auth" "cluster" {
  count      = var.create_eks_cluster ? 1 : 0
  name       = module.eks[0].cluster_name
  depends_on = [module.eks[0].cluster_arn]
}

provider "kubernetes" {
  host                   = module.eks[0].cluster_endpoint
  cluster_ca_certificate = module.eks[0].cluster_certificate_authority_data
  token                  = try(data.aws_eks_cluster_auth.cluster[0].token, "")
}

provider "helm" {
  kubernetes {
    host                   = module.eks[0].cluster_endpoint
    cluster_ca_certificate = module.eks[0].cluster_certificate_authority_data
    token                  = try(data.aws_eks_cluster_auth.cluster[0].token, "")
  }
}
