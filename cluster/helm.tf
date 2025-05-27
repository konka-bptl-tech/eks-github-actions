resource "null_resource" "kube-config" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.id} --region us-east-1"
  }
}

# resource "helm_release" "aws_lb_controller" {
#   depends_on = [module.eks, null_resource.kube-config]
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
  
#   set {
#     name  = "clusterName"
#     value = module.eks.id
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "region"
#     value = var.region
#   }

#   set {
#     name  = "vpcId"
#     value = module.eks_vpc.vpc_id
#   }
# }
