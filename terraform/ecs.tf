variable "aws_account_id" {}
variable "aws_region" {}

resource "aws_ecs_task_definition" "hello-world" {
  family                   = "hello-world"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = "${data.terraform_remote_state.core.ecs_execution_role_arn}"
  cpu                      = "256" // 0.25 vCPU
  memory                   = "512" // 512 MB

  container_definitions = <<DEFINITION
[
  {
    "cpu": 256,
    "memory": 512,
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/helloworld:latest",
    "name": "helloworld",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "hello-world" {
  name            = "hello-world"
  cluster         = "${data.terraform_remote_state.core.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.hello-world.arn}"
  desired_count   = "2"
  launch_type     = "FARGATE"


  network_configuration {
    security_groups = ["${data.terraform_remote_state.core.web_ecs_sg_id}"]
    subnets         = ["${data.terraform_remote_state.core.public_subnet_a_id}","${data.terraform_remote_state.core.public_subnet_b_id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.hello-world.id}"
    container_name   = "helloworld"
    container_port   = "8080"
  }

  depends_on = [
    "aws_alb_listener.hello-world",
  ]
}