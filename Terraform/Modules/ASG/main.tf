resource "aws_launch_template" "lt" {
  name_prefix   = "lt-${var.company_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file(var.user_data_script))

  vpc_security_group_ids = [var.security_group_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.company_name}-asg-instance"
      role        = "webserver"
      environment = "Prod"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.company_name}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.company_name}-asg-instance"
    propagate_at_launch = true
  }
}
