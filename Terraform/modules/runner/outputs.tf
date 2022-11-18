output "security_group_id" {
  description = "The Security Group ID of the Runner"
  value       = aws_security_group.runner.id
}

output "cluster_name" {
  description = "The Cluster name of the Runner"
  value       = aws_ecs_cluster.runner.name
}

output "task_definition" {
  description = "The Task Definition name of the Runner"
  value       = aws_ecs_task_definition.runner.family
}

output "container_name" {
  description = "The Container name of the Runner"
  value       = jsondecode(aws_ecs_task_definition.runner.container_definitions)[0]["name"]
}

output "log_stream_prefix" {
  description = "The Log Stream Prefix of the Runner"
  value       = aws_cloudwatch_log_group.runner.name
}

output "log_group" {
  description = "The Log Group name of the Runner"
  value       = aws_cloudwatch_log_group.runner.name
}
