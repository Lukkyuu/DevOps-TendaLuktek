# Application Load Balancer
resource "aws_lb" "main" {
  name               = "tienda-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "tienda-alb"
  }
}

# Target Group para el Frontend (puerto 80)
resource "aws_lb_target_group" "frontend" {
  name        = "tienda-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

# Listener del ALB (redirecciona el tráfico del puerto 80 al Target Group del Frontend)
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

output "alb_dns_name" {
  description = "URL publica del Frontend"
  value       = aws_lb.main.dns_name
}

# Target Group para Ventas (puerto 8080)
resource "aws_lb_target_group" "ventas" {
  name        = "tienda-ventas-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/*"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "ventas_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ventas.arn
  }
}

# Target Group para Despachos (puerto 8081)
resource "aws_lb_target_group" "despachos" {
  name        = "tienda-despachos-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/*"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "despachos_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8081"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.despachos.arn
  }
}
