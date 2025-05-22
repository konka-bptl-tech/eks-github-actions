resource "aws_eks_access_entry" "example" {
  cluster_name      = var.cluster_name
  principal_arn     = var.principal_arn
  kubernetes_groups = var.kubernetes_groups
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "example" {
  depends_on = [ aws_eks_access_entry.example ]
  cluster_name  = var.cluster_name
  policy_arn    = var.policy_arn
  principal_arn = var.principal_arn
  access_scope {
    type       = "cluster"
  }
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
variable "principal_arn" {
  description = "The ARN of the IAM principal (user or role)."
  type        = string
}
variable "kubernetes_groups" {
  description = "List of Kubernetes groups to associate with the IAM principal."
  type        = list(string)
  default     = []
}
variable "policy_arn" {
  description = "The ARN of the IAM policy to associate with the EKS access entry."
  type        = string
}
