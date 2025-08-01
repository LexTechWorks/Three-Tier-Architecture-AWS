resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type          = "gp3"
      encrypted            = true
      delete_on_termination = true
      iops                 = 3000 
      throughput           = 125  
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                = "required"  # IMDSv2 requirement
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true  # Enable detailed monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name        = "${var.name_prefix}-instance"
        Environment = var.environment
        ManagedBy   = "terraform"
        Tier        = "application"
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name        = "${var.name_prefix}-volume"
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}-asg"
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }
}