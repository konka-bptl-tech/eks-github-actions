variable "environment" {
  description = "The environment for the EKS Pod Identity module."
  type        = string
}
variable "project_name" {
  description = "The project name for the EKS Pod Identity module."
  type        = string
}
variable "pod_identity_role_name" {
  description = "The name of the Pod Identity role."
  type        = string
}
variable "policy_statements" {
  description = "The policy statements for the Pod Identity role."
  type        = list(object({
    Effect    = string
    Action    = list(string)
    Resource  = list(string)
  }))
  default     = []
}
variable "managed_policy_arns" {
  description = "The managed policy ARNs to attach to the Pod Identity role."
  type        = list(string)
  default     = []
}
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
variable "namespace" {
  description = "The namespace for the EKS Pod Identity."
  type        = string
}
variable "service_account" {
  description = "The service account for the EKS Pod Identity."
  type        = string
}