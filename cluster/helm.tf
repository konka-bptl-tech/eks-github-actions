resource "null_resource" "kube-bootstrap" {
  depends_on = [aws_eks_cluster.example]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.id}"
  }
}