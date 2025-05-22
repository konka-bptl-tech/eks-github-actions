variable "environment" {
  description = "The environment for the EKS cluster (e.g., dev, staging, prod)."
  type        = string
}
variable "project_name" {
  description = "The name of the project."
  type        = string
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster."
  type        = list(string)
}
variable "eks_version" {
  description = "The version of the EKS cluster."
  type        = string
}
variable "access_cidr" {
  description = "List of CIDR blocks for public access to the EKS cluster."
  type        = list(string)
}
variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be created."
  type        = string
}
variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
variable "node_groups" {}
variable "addons" {}
variable "eks_iam_access" {}