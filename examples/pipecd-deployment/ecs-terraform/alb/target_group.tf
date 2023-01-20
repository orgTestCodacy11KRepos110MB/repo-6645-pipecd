resource "aws_lb_target_group" "main" {
  name                 = var.project
  deregistration_delay = "300"
  health_check {
    enabled             = true
    healthy_threshold   = "5"
    interval            = "300"
    matcher             = "200"
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  port                          = "80"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = false
    type            = "lb_cookie"
  }

  target_type = "ip"
  vpc_id      = var.vpc_id
  tags        = var.tags
}