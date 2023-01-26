resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "${var.project}-ecs-task-execution"
  }
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}
# for ssm (parameter store)
resource "aws_iam_policy" "ssm" {
  name = "${var.project}-ssm"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:parameter${var.path_to_encryption_key}"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ssm.arn
}

# enable ecs to access config file
resource "aws_iam_policy" "config_access" {
  name = "${var.project}-s3-config"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "s3:GetObject"
          "Resource" : "arn:aws:s3:::${var.config_bucket_name}/*"
        },
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_config_access" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.config_access.arn
}

# enable ecs to access filestore 
resource "aws_iam_policy" "filestore_access" {
  name = "${var.project}-s3-filestore"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "s3:*"
          "Resource" : "arn:aws:s3:::${var.filestore_bucket_name}/*"
        },
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_filestore_access" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.filestore_access.arn
}

# for ECS exec
resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-ecs-task"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "${var.project}-ecs-task"
  }
}

resource "aws_iam_role_policy" "ecs_task_ssm" {
  name = "${var.project}-ssm"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}