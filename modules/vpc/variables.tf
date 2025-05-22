variable "environment" {
  description = "The environment for the VPC (e.g., dev, staging, prod)"
  type        = string
}
variable "project_name" {
  description = "The name of the project"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the VPC"
  type        = map(string)
  default     = {}
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}
variable "availability_zone" {
  description = "The availability zone for the public subnets"
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}
variable "db_subnet_cidrs" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
}
variable "create_nat" {
  description = "Whether to create a NAT gateway"
  type        = bool
}