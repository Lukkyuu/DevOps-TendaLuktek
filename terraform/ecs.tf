# Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "tienda-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]
}

# Log Groups para CloudWatch
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/tienda-frontend"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "ventas" {
  name              = "/ecs/tienda-ventas"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "despachos" {
  name              = "/ecs/tienda-despachos"
  retention_in_days = 7
}

# Task Definitions
resource "aws_ecs_task_definition" "frontend" {
  family                   = "tienda-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::801716241958:role/LabRole"
  task_role_arn            = "arn:aws:iam::801716241958:role/LabRole"

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.ecr_frontend_url
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    environment = [
      { name = "BACKEND_VENTAS_HOST", value = "http://${aws_lb.main.dns_name}:8080" },
      { name = "BACKEND_DESPACHOS_HOST", value = "http://${aws_lb.main.dns_name}:8081" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/tienda-frontend"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "ventas" {
  family                   = "tienda-ventas-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::801716241958:role/LabRole"
  task_role_arn            = "arn:aws:iam::801716241958:role/LabRole"

  container_definitions = jsonencode([{
    name      = "ventas-backend"
    image     = var.ecr_ventas_url
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
    environment = [
      { name = "DB_ENDPOINT", value = var.db_host },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "tienda_luktek" },
      { name = "DB_USERNAME", value = "root" },
      { name = "DB_PASSWORD", value = "admin123" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/tienda-ventas"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "despachos" {
  family                   = "tienda-despachos-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::801716241958:role/LabRole"
  task_role_arn            = "arn:aws:iam::801716241958:role/LabRole"

  container_definitions = jsonencode([{
    name      = "despachos-backend"
    image     = var.ecr_despachos_url
    essential = true
    portMappings = [{
      containerPort = 8081
      hostPort      = 8081
    }]
    environment = [
      { name = "DB_ENDPOINT", value = var.db_host },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "tienda_luktek" },
      { name = "DB_USERNAME", value = "root" },
      { name = "DB_PASSWORD", value = "admin123" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/tienda-despachos"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# Servicios ECS
resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "ventas" {
  name            = "ventas-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ventas.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ventas.arn
    container_name   = "ventas-backend"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "despachos" {
  name            = "despachos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.despachos.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.despachos.arn
    container_name   = "despachos-backend"
    container_port   = 8081
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
