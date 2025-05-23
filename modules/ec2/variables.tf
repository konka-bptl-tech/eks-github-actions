variable "environment" {
  description = "The environment to use for the instance"
  type        = string
}
variable "project_name" {
  description = "The project to use for the instance"
  type        = string
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(any)
}
variable "instance_name" {
  description = "The name of the instance"
  type        = string
}
variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}
variable "instance_type" {
  description = "The instance type to use for the instance"
  type        = string
}
variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}
variable "security_groups" {
  description = "The security groups to use for the instance"
  type        = list(string)
}
variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}
variable "subnet_id" {
  description = "The subnet ID to use for the instance"
  type        = string
}
variable "user_data" {
  type        = string
  default     = null
  description = "User data script content to run on EC2 (optional)"
}

variable "use_null_resource_for_userdata" {
  type        = bool
  default     = false
  description = "If true, executes user_data via null_resource and remote-exec"
}

variable "remote_exec_user" {
  description = "The user to use for remote execution"
  type        = string
  default     = ""
}

variable "private_key" {
  description = "The path to the private key file"
  type        = string
  default     = ""
}
variable "iam_instance_profile" {
  description = "The IAM instance profile to use for the instance"
  type        = string
}
