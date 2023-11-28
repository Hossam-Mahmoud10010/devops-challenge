output "ecr_repo_url" {
  value = aws_ecr_repository.this.repository_url
}

output "application_url" {
  value = aws_alb.this.dns_name
}