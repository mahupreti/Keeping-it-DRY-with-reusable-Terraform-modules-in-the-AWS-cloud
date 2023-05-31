provider "aws" {
  region  = var.region
  profile = "default"

}

#create vpc (referencing the module)

module "vpc" {
  source                 = "../modules/vpc"
  region                 = var.region
  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  #   private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  #   private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}


#create nat gateway

module "nat_gateway" {
  source                     = "../modules/nat-gateway"
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

#create security group
module "sg" {
  source = "../modules/sg"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

#create ssl certificate
module "acm" {
  source           = "../modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
}

#create application load balancer

module "lb" {
  source                             = "../modules/lb"
  project_name                       = module.vpc.project_name
  public_instance_security_group_id  = module.sg.public_instance_security_group_id
  public_subnet_az1_id               = module.vpc.public_subnet_az1_id
  public_subnet_az2_id               = module.vpc.public_subnet_az2_id
  private_data_subnet_az1_id         = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id         = module.vpc.private_data_subnet_az2_id
  private_instance_security_group_id = module.sg.private_instance_security_group_id

  vpc_id                                = module.vpc.vpc_id
  public_loadbalancer_target_group_arn  = module.lb.public_loadbalancer_target_group_arn
  private_loadbalancer_target_group_arn = module.lb.private_loadbalancer_target_group_arn
  aws_acm_certificate_validation_acm_certificate_validation_arn = module.acm.aws_acm_certificate_validation_acm_certificate_validation_arn


}

#create autoscaling groups
module "auto-sg" {
  source                                = "../modules/auto-sg"
  project_name                          = module.vpc.project_name
  image_name                            = var.image_name
  instance_type                         = var.instance_type
  public_subnet_az1_id                  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id                  = module.vpc.public_subnet_az2_id
  private_data_subnet_az1_id            = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id            = module.vpc.private_data_subnet_az2_id
  desired_capacity                      = var.desired_capacity
  min_size                              = var.min_size
  max_size                              = var.max_size
  vpc_id                                = module.vpc.vpc_id
  public_loadbalancer_target_group_arn  = module.lb.public_loadbalancer_target_group_arn
  private_loadbalancer_target_group_arn = module.lb.private_loadbalancer_target_group_arn
  public_instance_security_group_id     = module.sg.public_instance_security_group_id
  private_instance_security_group_id    = module.sg.private_instance_security_group_id
  public_loadbalancer_arn               = module.lb.public_loadbalancer_arn
  private_loadbalancer_arn              = module.lb.private_loadbalancer_arn
  private_loadbalancer_id = module.lb.private_loadbalancer_id
  aws_lb_listener_alb_public_https_listener_arn= module.lb.aws_lb_listener_alb_public_https_listener_arn
}

module "route-53" {
  source                     = "../modules/route53"
  aws_lb_public_alb_dns_name = module.lb.aws_lb_public_alb_dns_name
  aws_lb_public_alb_zone_id  = module.lb.aws_lb_public_alb_zone_id
  # ipv4_address = module.auto-sg.ipv4_address
}