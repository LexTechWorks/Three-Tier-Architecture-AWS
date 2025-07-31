resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file(var.user_data_script))

  vpc_security_group_ids = [var.security_group_id]

  metadata_options {
    http_tokens               = "required"  # Habilita IMDSv2
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true  # Habilita monitoramento detalhado
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted            = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name        = "${var.name_prefix}-instance"
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]
  
  health_check_type         = "ELB"  # Alterado para ELB
  health_check_grace_period = 300    # Aumentado para 5 minutos

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name        = "${var.name_prefix}-asg"
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Políticas de Auto Scaling
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.name_prefix}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown              = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.name_prefix}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown              = 300
}
