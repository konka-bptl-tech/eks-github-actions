resource "null_resource" "kube-bootstrap" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.id}"
  }
}