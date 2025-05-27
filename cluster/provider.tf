terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {}
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
