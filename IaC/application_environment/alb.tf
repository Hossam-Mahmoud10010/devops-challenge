resource "aws_alb" "this" {
  load_balancer_type = "application"
  name               = "application-load-balancer"
  subnets            = aws_subnet.public_subnets.*.id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_alb_target_group" "this" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/healthcheck"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
}