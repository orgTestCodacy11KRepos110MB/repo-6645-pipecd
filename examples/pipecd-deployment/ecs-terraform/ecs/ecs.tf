resource "aws_ecs_cluster" "this" {
  name = var.project

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "${var.project}"
  }
}

resource "aws_ecs_task_definition" "this" {
  family        = var.project
  task_role_arn = aws_iam_role.ecs_task.arn
  network_mode  = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  memory             = "512"
  cpu                = "256"
  container_definitions = jsonencode(
    [
      {
        name  = "pipecd-gateway"
        image = var.gateway_image_url
        portMappings = [
          {
            hostPort      = 9090
            containerPort = 9090
            protocol      = "tcp"
          }
        ]
        essential = false
        command = [
          "/bin/sh -c 'apk update; apk add curl; curl https://${var.config_bucket_name}.s3.${data.aws_region.current.id}.amazonaws.com/envoy-config.yaml >> envoy-config.yaml; envoy -c envoy-config.yaml;'"
        ]
        entrypoint = [
          "sh",
          "-c"
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.log_group_name
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "${var.project}-pipecd-gateway"
          }
        }
      },
      {
        name  = "pipecd-server"
        image = var.server_image_url
        portMappings = [
        ]
        command = [
          "/bin/sh -c 'curl https://${var.config_bucket_name}.s3.${data.aws_region.current.id}.amazonaws.com/control-plane-config.yaml >> control-plane-config.yaml; sed -i -e s/pipecd-mysql/${var.db_instance_address}/ control-plane-config.yaml; cat control-plane-config.yaml; echo $ENCRYPTION_KEY >> encryption-key; pipecd server --insecure-cookie=true --cache-address=${var.redis_host}:6379 --config-file=control-plane-config.yaml --enable-grpc-reflection=false --encryption-key-file=encryption-key --log-encoding=humanize --metrics=true;'"
        ]
        entrypoint = [
          "sh",
          "-c"
        ]
        secrets = [ {"name" : "ENCRYPTION_KEY", "valueFrom" : "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:parameter${var.path_to_encryption_key}" }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.log_group_name
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "${var.project}-pipecd-server"
          }
        }
      },
      {
        name  = "pipecd-ops"
        image = var.ops_image_url
        portMappings = [
        ]
        command = [
          "/bin/sh -c 'curl https://${var.config_bucket_name}.s3.${data.aws_region.current.id}.amazonaws.com/control-plane-config.yaml >> control-plane-config.yaml; sed -i -e s/pipecd-mysql/${var.db_instance_address}/ control-plane-config.yaml; echo $ENCRYPTION_KEY >> encryption-key; pipecd server --insecure-cookie=true --cache-address=${var.redis_host}:6379 --config-file=control-plane-config.yaml --enable-grpc-reflection=false --encryption-key-file=encryption-key --log-encoding=humanize --metrics=true;'"
        ]
        entrypoint = [
          "sh",
          "-c"
        ]
        secrets = [ {"name" : "ENCRYPTION_KEY", "valueFrom" : "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:parameter${var.path_to_encryption_key}" }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.log_group_name
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "${var.project}-pipecd-ops"
          }
        }
      },
    ]
  )
  tags = {
    Name = "new-bus-main"
  }
}
resource "aws_ecs_service" "this" {
  name    = var.project
  cluster = aws_ecs_cluster.this.arn
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }
  platform_version                   = "1.4.0"
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  depends_on                         = [aws_iam_role.ecs_task_execution]
  load_balancer {
    container_name   = "pipecd-gateway"
    container_port   = 9090
    target_group_arn = var.lb_target_group_arn
  }
  health_check_grace_period_seconds = 60
  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.web.id
    ]
    subnets = [
      var.subnet_id
    ]
  }
  enable_execute_command = true
  tags = {
    Name = "${var.project}"
  }
}