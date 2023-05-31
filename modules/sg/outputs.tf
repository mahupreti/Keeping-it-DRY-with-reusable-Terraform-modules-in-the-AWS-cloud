output "public_instance_security_group_id" {
  value = aws_security_group.public_instance_security_group.id
}

output "private_instance_security_group_id" {
    value = aws_security_group.private_instance_security_group.id
  
}