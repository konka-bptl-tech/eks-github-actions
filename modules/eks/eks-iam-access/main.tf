resource "aws_eks_access_entry" "example" {
  cluster_name      = var.cluster_name
  principal_arn     = var.principal_arn
  kubernetes_groups = var.kubernetes_groups
  type              = "STANDARD"
}

# resource "aws_eks_access_policy_association" "example" {
#   depends_on = [ aws_eks_access_entry.example ]
#   cluster_name  = var.cluster_name
#   policy_arn    = var.policy_arn
#   principal_arn = var.principal_arn
#   access_scope {
#     type       = "cluster"
#   }
# }

# resource "aws_eks_access_policy_association" "example" {
#   cluster_name  = var.cluster_name
#   policy_arn    = var.policy_arn
#   principal_arn = var.principal_arn

#   dynamic "access_scope" {
#     for_each = var.access_type == "namespace" ? [1] : []

#     content {
#       type       = "namespace"
#       namespaces = var.namespaces
#     }
#   }

#   # If type is cluster, define a static block outside dynamic
#   lifecycle {
#     ignore_changes = [access_scope]
#   }
# }

# resource "aws_eks_access_policy_association" "cluster_scope" {
#   count        = var.access_type == "cluster" ? 1 : 0
#   cluster_name = var.cluster_name
#   policy_arn   = var.policy_arn
#   principal_arn = var.principal_arn

#   access_scope {
#     type = "cluster"
#   }
# }

resource "aws_eks_access_policy_association" "cluster_scope" {
  count        = var.access_type == "cluster" ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn   = var.policy_arn
  principal_arn = var.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "namespace_scope" {
  count        = var.access_type == "namespace" ? 1 : 0
  cluster_name = var.cluster_name
  policy_arn   = var.policy_arn
  principal_arn = var.principal_arn

  access_scope {
    type       = "namespace"
    namespaces = var.namespaces
  }
}

variable "access_type" {
  type    = string
  default = "cluster"  # or "namespace"
}

variable "namespaces" {
  type    = list(string)
  default = []
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
