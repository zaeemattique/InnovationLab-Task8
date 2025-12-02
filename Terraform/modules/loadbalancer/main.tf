resource "aws_lb" "Task8-ALB-A-Zaeem" {
  name               = "Task8-ALB-A-Zaeem"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnetA_id, var.public_subnetB_id]

  tags = {
    Name = "Task8-ALB-A-Zaeem"
  }
  
}

resource "aws_lb_listener" "Task8-ALB-B-Zaeem" {
  load_balancer_arn = aws_lb.Task8-ALB-A-Zaeem.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Task8-ALB-Target-Group-Zaeem.arn
  }
}

resource "aws_lb_target_group" "Task8-ALB-Target-Group-Zaeem" {
  name     = "Task8-ALB-Target-Group-Zaeem"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Task8-ALB-Target-Group-Zaeem"
  }
  
}
