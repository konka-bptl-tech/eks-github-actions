terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region
}
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }