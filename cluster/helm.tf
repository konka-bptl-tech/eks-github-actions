resource "null_resource" "kube-config" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${module.eks.id} --region us-east-1
kubectl get pods -A
EOF
  }
}