terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
  backend "s3" {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {}