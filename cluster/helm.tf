resource "null_resource" "kube-config" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.id} --region us-east-1"
  }
}