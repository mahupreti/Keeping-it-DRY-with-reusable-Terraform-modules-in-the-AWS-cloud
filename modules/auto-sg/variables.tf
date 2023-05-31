variable "project_name" {}
variable "image_name" {}
variable "instance_type" {}
variable "public_subnet_az1_id" {}
variable "public_subnet_az2_id" {}
variable "private_data_subnet_az1_id" {}
variable "private_data_subnet_az2_id" {}
variable "desired_capacity"{}
variable "min_size"{}
variable "max_size"{}
variable "vpc_id" {}
variable "public_loadbalancer_target_group_arn"{}
variable "private_loadbalancer_target_group_arn"{}
variable "public_instance_security_group_id"{}
variable "private_instance_security_group_id"{}
variable "public_loadbalancer_arn"{}
variable "private_loadbalancer_arn"{}
variable "private_loadbalancer_id" {}
variable "aws_lb_listener_alb_public_https_listener_arn" {}