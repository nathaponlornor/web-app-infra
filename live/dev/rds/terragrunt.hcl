include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id              = "vpc-mock"
    private_db_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "ecs" {
  config_path = "../ecs"

  mock_outputs = {
    ecs_security_group_id = "sg-mock"
  }
}

inputs = {
  vpc_id                = dependency.vpc.outputs.vpc_id
  private_db_subnet_ids = dependency.vpc.outputs.private_db_subnet_ids
  ecs_security_group_id = dependency.ecs.outputs.ecs_security_group_id
  db_instance_class     = "db.t3.medium"
  db_name               = "appdb"
  db_username           = "dbadmin"
}
