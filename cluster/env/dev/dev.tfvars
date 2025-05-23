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
  eks_version = "1.31"
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
    kube-proxy             = "v1.31.7-eksbuild.7"
    coredns                = "v1.11.4-eksbuild.10"
    eks-pod-identity-agent = "v1.3.7-eksbuild.2"
  }
  eks_iam_access = {
    admin = {
      principal_arn     = "arn:aws:iam::522814728660:root"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      kubernetes_groups = []
    }
    siva = {
      principal_arn     = "arn:aws:iam::522814728660:role/siva"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      kubernetes_groups = []
    }
  }
}

# aws eks describe-addon-versions --addon-name coredns --query "addons[0].addonVersions[*].addonVersion" --output text

# aws eks describe-addon-versions \
#   --addon-name kube-proxy \
#   --kubernetes-version 1.31

siva_instance = { 
  instance_name = "siva-ec2-instance" 
  instance_type  = "t3.micro"
  key_name  = "siva"
  monitoring  = false
  use_null_resource_for_userdata  = true
  remote_exec_user = "ec2-user"
  user_data  = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install git tmux -y
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.7/2025-04-17/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    curl -sS https://webinstall.dev/k9s | bash
    aws eks update-kubeconfig --name dev-eks-tf-eks-cluster --region us-east-1
    EOF
  iam_instance_profile = "siva"
}