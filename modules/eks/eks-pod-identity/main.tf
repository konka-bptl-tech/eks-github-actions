resource "aws_iam_role" "this" {
  name = "${var.environment}-${var.project_name}-eks-${var.pod_identity_role_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["pods.eks.amazonaws.com"]
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# Attach an inline policy only if policy_statements is provided
resource "aws_iam_policy" "inline" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  name   = "${var.environment}-${var.project_name}-eks-${var.pod_identity_role_name}-inline-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : var.policy_statements
  })
}

resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.managed_policy_arns[count.index]
}

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
}
