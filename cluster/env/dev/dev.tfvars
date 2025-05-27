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

# VPC
vpc = {
  vpc_cidr             = "10.1.0.0/16"
  availability_zone    = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
  db_subnet_cidrs      = ["10.1.21.0/24", "10.1.22.0/24"]
  create_nat           = true
}

# EKS Cluster
eks = {
  eks_version = "1.31"
  access_cidr = ["0.0.0.0/0"]
  endpoint_private_access = true
  endpoint_public_access  = false
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
    metrics-server         = "v0.7.2-eksbuild.3"
    aws-ebs-csi-driver     = "v1.43.0-eksbuild.1"

  }
  eks_iam_access = {
    admin = {
      principal_arn     = "arn:aws:iam::522814728660:root"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      kubernetes_groups = [""]
      access_scope_type = "cluster" 
    }
    siva = {
      principal_arn     = "arn:aws:iam::522814728660:role/siva"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      kubernetes_groups = [""]
      access_scope_type = "cluster" 
    }
    bptl = {
      principal_arn     = "arn:aws:iam::522814728660:user/eks-siva.bapatlas.site"
      policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      kubernetes_groups = [""]
      access_scope_type = "cluster" 
    }
    # hello = {
    #   principal_arn     = "arn:aws:iam::522814728660:role/hello"
    #   policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
    #   kubernetes_groups = []
    #   access_scope_type = "namespace"
    #   namespaces        = ["default"]
    # }
    # hi = {
    #   principal_arn     = "arn:aws:iam::522814728660:role/hi"
    #   policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
    #   kubernetes_groups = []
    #   access_scope_type = "namespace"
    #   namespaces        = ["kube-system"]
    # }
  }
}

# aws eks describe-addon-versions --addon-name coredns --query "addons[0].addonVersions[*].addonVersion" --output text

# aws eks describe-addon-versions --addon-name metric-server --kubernetes-version 1.31

# aws eks list-access-policies --region us-east-1

# Siva EC2 Instance
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
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.7/2025-04-17/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    curl -sS https://webinstall.dev/k9s | bash
    aws eks update-kubeconfig --name dev-eks-tf-eks-cluster --region us-east-1
    echo "alias k=kubectl" >> /home/ec2-user/.bashrc
    source /home/ec2-user/.bashrc
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    EOF
  iam_instance_profile = "siva"
}

# EBS Pod Identity
ebs_pod_identity = {
  namespace               = "kube-system"
  service_account         = "ebs-csi-controller-sa"
  pod_identity_role_name  = "ebs-csi-controller-sa"
  managed_policy_arns     = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}