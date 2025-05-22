common_variables = {
  environment  = "dev"
  project_name = "eks-tf"
  tags = {
    "Name"        = "eks-tf"
    "Environment" = "dev"
    "Project"     = "eks-tf"
    "Terraform"   = "true"
  }
}
vpc = {
  vpc_cidr             = "10.1.0.0/16"
  availability_zone    = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
  db_subnet_cidrs      = ["10.1.21.0/24", "10.1.22.0/24"]
  create_nat           = true
}
eks = {
  eks_version = "1.32"
  access_cidr = ["0.0.0.0/0"]
  node_groups = {
    blue = {
      instance_types = ["t3a.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 3
      min_size       = 1
    }
  }
  addons = {
    vpc-cni                = "v1.19.5-eksbuild.1"
    kube-proxy             = "v1.32.3-eksbuild.2"
    coredns                = "v1.11.4-eksbuild.2"
    eks-pod-identity-agent = "v1.3.5-eksbuild.2"
  }
  eks_iam_access = {
    admin = {
      principal_arn     = "arn:aws:iam::522814728660:root"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      kubernetes_groups = []
    }
  }
}

# aws eks describe-addon-versions --addon-name coredns --query "addons[0].addonVersions[*].addonVersion" --output text
