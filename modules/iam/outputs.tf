output "ecs_instance_profile_arn" {
  value = aws_iam_instance_profile.ecs.arn
}

output "ecs_instance_role_name" {
  value = aws_iam_role.ecs_instance.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}
