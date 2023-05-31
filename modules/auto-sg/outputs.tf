output "public_launch_arn"{
    value = aws_launch_template.public_launch_template.arn
}

output "public_launch_id"{
    value = aws_launch_template.public_launch_template.id
}

# output "private_launch_arn"{
#     value = aws_launch_template.private_launch_template.arn
# }

# output "private_launch_id"{
#     value = aws_launch_template.private_launch_template.id
# }

# output "public_instance_ip_id" {
#   value= aws_eip.public_instance_ip.id
# }

