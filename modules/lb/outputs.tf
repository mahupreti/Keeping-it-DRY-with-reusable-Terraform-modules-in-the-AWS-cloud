output "public_loadbalancer_id" {
    value= aws_lb.public_alb.id
}
output "aws_lb_public_alb_dns_name" {
  value = aws_lb.public_alb.dns_name

}
output "aws_lb_public_alb_zone_id"{
  value = aws_lb.public_alb.zone_id

}

output "public_loadbalancer_arn" {
    value= aws_lb.public_alb.arn
}

output "public_loadbalancer_target_group_id" {
  value= aws_lb_target_group.alb_public_target_group.id
}

output "public_loadbalancer_target_group_arn" {
  value= aws_lb_target_group.alb_public_target_group.arn
}

# output "private_loadbalancer_id" {
#     value= aws_lb.private_alb.id
# }

# output "private_loadbalancer_arn" {
#     value= aws_lb.private_alb.arn
# }

# output "private_loadbalancer_target_group_id" {
#   value= aws_lb_target_group.alb_private_target_group.id
# }

# output "private_loadbalancer_target_group_arn" {
#   value= aws_lb_target_group.alb_private_target_group.arn
# }

output "aws_lb_listener_alb_public_https_listener_arn" {
  value = aws_lb_listener.alb_public_https_listener.arn
}