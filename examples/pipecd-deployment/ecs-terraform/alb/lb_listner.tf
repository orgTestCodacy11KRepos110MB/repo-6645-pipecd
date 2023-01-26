# edit if you would like to use HTTPS

resource "aws_lb_listener" "main" {
  port     = "9090"
  protocol = "HTTP"
  depends_on = [aws_lb_target_group.main]

  load_balancer_arn = aws_lb.main.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}