# resource "aws_eip" "public_instance_ip" {
#   vpc = true
# }

# resource "aws_eip_association" "example" {
#   instance_id   = data.aws_instances.this.ids[count.index]
#   allocation_id = aws_eip.public_instance_ip.id
# }

resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id_rsa.pub")
}

#create launch template for ec2 instance in public subnet
resource "aws_launch_template" "public_launch_template" {
  name     = "${var.project_name}-publiclaunch-template"
  image_id   = data.aws_ami.ami.id
  instance_type = var.instance_type 
  key_name  = aws_key_pair.key-tf.key_name
  user_data =  filebase64("../modules/auto-sg/ec2-init.sh")
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      delete_on_termination= true
    }
  }

  monitoring {
    enabled =true

  }

  placement {
    availability_zone = "all"
    tenancy = "default"
  }

  # vpc_security_group_ids= [var.public_instance_security_group_id]

  network_interfaces {
  associate_public_ip_address = true
  security_groups = [var.public_instance_security_group_id]

  }

  tag_specifications {
    resource_type = "instance"
    tags   =  {
      name=   "public launch template"
  }

    }    

  # depends_on = [
  #   aws_security_group.lb_sg
  # ]
}

#create autoscaling group
resource "aws_autoscaling_group" "public_autoscaling_group" {

  name                      = "${var.project_name}-autoscaling-group"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  target_group_arns   = [var.public_loadbalancer_target_group_arn] 

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.public_launch_template.id
    version = aws_launch_template.public_launch_template.latest_version 
  }
  depends_on = [aws_launch_template.public_launch_template]
  # load_balancers = [var.public_loadbalancer_arn]

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

# scale up policy
resource "aws_autoscaling_policy" "public_scale_up" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.public_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "public_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" 
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.public_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.public_scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "public_scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.public_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "public_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.public_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.public_scale_down.arn]
}


#create launch template for ec2 instance in private subnets 
resource "aws_launch_template" "private_launch_template" {
  name          = "${var.project_name}-privatelaunch-template"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type 
  key_name  = aws_key_pair.key-tf.key_name
  user_data = filebase64("../modules/auto-sg/data.sh")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      delete_on_termination= false
    }
  }

  monitoring {
    enabled =true

  }

  placement {
    availability_zone = "all"
    tenancy = "default"
  }

  # vpc_security_group_ids = [var.private_instance_security_group_id]

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.private_instance_security_group_id]

  }

  tag_specifications {
    resource_type = "instance"
   tags   =  {
      name=   "public launch template"
  }
}
}
#create autoscaling group
resource "aws_autoscaling_group" "private_autoscaling_group" {

  name                      = "${var.project_name}-privateautoscaling-group"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier = [var.private_data_subnet_az1_id, var.private_data_subnet_az2_id]
  target_group_arns   = [var.private_loadbalancer_target_group_arn] 

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.private_launch_template.id
    version = aws_launch_template.private_launch_template.latest_version 
  }
  depends_on = [aws_launch_template.private_launch_template]
  # load_balancers = [var.private_loadbalancer_arn]

  tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }
}

# scale up policy
resource "aws_autoscaling_policy" "private_scale_up" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "private_scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" 
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.private_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.private_scale_up.arn]
}

# scale down policy
resource "aws_autoscaling_policy" "private_scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "private_scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.private_autoscaling_group.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.private_scale_down.arn]
}


# attach target group load balancer 
# resource "aws_lb_target_group_attachment" "private_alb_attachment" {
#   target_group_arn = var.private_loadbalancer_target_group_arn
#   target_id        = aws_autoscaling_group.private_autoscaling_group.id
#   port             = 443
# }

# attach target group load balancer public
# resource "aws_lb_target_group_attachment" "public_alb_attachment" {
#   target_group_arn = var.public_loadbalancer_target_group_arn
#   target_id        = var.public_loadbalancer_arn
#   port             = 443

# }

# # attach target group load balancer private
# resource "aws_lb_target_group_attachment" "private_alb_attachment" {
#   target_group_arn = var.private_loadbalancer_target_group_arn
#   target_id        = var.aws_lb_listener_alb_public_https_listener_arn
#   port             = 443
# }
