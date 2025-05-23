module "eks_vpc" {
  source               = "../modules/vpc"
  environment          = var.common_variables["environment"]
  project_name         = var.common_variables["project_name"]
  tags                 = var.common_variables["tags"]
  vpc_cidr             = var.vpc["vpc_cidr"]
  availability_zone    = var.vpc["availability_zone"]
  public_subnet_cidrs  = var.vpc["public_subnet_cidrs"]
  private_subnet_cidrs = var.vpc["private_subnet_cidrs"]
  db_subnet_cidrs      = var.vpc["db_subnet_cidrs"]
  create_nat           = var.vpc["create_nat"]
}
module "eks" {
  source             = "../modules/eks"
  depends_on         = [module.eks_vpc]
  environment        = var.common_variables["environment"]
  project_name       = var.common_variables["project_name"]
  tags               = var.common_variables["tags"]
  eks_version        = var.eks["eks_version"]
  access_cidr        = var.eks["access_cidr"]
  private_subnet_ids = module.eks_vpc.private_subnet_ids
  vpc_id             = module.eks_vpc.vpc_id
  node_groups        = var.eks["node_groups"]
  addons             = var.eks["addons"]
  eks_iam_access     = var.eks["eks_iam_access"]
}
module "siva_ec2_instance" {
  depends_on                     = [module.eks]
  source                         = "../modules/ec2"
  environment                    = var.common_variables["environment"]
  project_name                   = var.common_variables["project_name"]
  common_tags                    = var.common_variables["tags"]
  instance_name                  = var.siva_instance["instance_name"]
  ami                            = data.aws_ami.amazon_linux.id
  instance_type                  = var.siva_instance["instance_type"]
  key_name                       = var.siva_instance["key_name"]
  security_groups                = [module.eks_vpc.sg_id]
  monitoring                     = var.siva_instance["monitoring"]
  subnet_id                      = module.eks_vpc.public_subnet_ids[0]
  user_data                      = var.siva_instance["user_data"]
  use_null_resource_for_userdata = var.siva_instance["use_null_resource_for_userdata"]
  remote_exec_user               = var.siva_instance["remote_exec_user"]
  private_key                    = data.aws_ssm_parameter.ec2_key.value
  iam_instance_profile           = var.siva_instance["iam_instance_profile"]
}


