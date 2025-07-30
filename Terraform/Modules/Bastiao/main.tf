resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Permitir acesso SSH ao Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_launch_template" "bastion_lt" {
  name_prefix            = "bastion-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = base64encode(file(var.user_data_script))
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "bastion-instance"
      environment = "Prod"
      role        = "bastion"
    }
  }
}

resource "aws_lb" "bastion_nlb" {
  name               = "bastion-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "bastion_tg" {
  name     = "bastion-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "bastion_listener" {
  load_balancer_arn = aws_lb.bastion_nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion_tg.arn
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "bastion-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.bastion_tg.arn]

  tag {
    key                 = "Name"
    value               = "bastion-instance"
    propagate_at_launch = true
  }
}