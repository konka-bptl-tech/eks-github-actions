output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnet[*].id
}
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnet[*].id
}
output "db_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.db_subnet[*].id
}
output "sg_id" {
  description = "List of NAT Gateway IDs"
  value = aws_security_group.allow_all.id
}
