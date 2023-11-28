resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${var.app_name}"
  retention_in_days = var.app_logs_retention_days
  tags = {
    Application = var.app_name
  }
}