include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                     = "vpc-mock"
    private_backend_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    alb_security_group_id = "sg-mock"
    target_group_arn      = "arn:aws:elasticloadbalancing:ap-southeast-1:000000000000:targetgroup/mock/mock"
  }
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs = {
    ecs_instance_profile_arn = "arn:aws:iam::000000000000:instance-profile/mock"
    task_execution_role_arn  = "arn:aws:iam::000000000000:role/mock-exec"
    task_role_arn            = "arn:aws:iam::000000000000:role/mock-task"
  }
}

inputs = {
  vpc_id                   = dependency.vpc.outputs.vpc_id
  private_subnet_ids       = dependency.vpc.outputs.private_backend_subnet_ids
  alb_security_group_id    = dependency.alb.outputs.alb_security_group_id
  target_group_arn         = dependency.alb.outputs.target_group_arn
  ecs_instance_profile_arn = dependency.iam.outputs.ecs_instance_profile_arn
  task_execution_role_arn  = dependency.iam.outputs.task_execution_role_arn
  task_role_arn            = dependency.iam.outputs.task_role_arn
  instance_type            = "t3.small"
  desired_capacity         = 2
  container_image          = "nginx:latest"
  container_port           = 8080
  task_cpu                 = 256
  task_memory              = 512
}
