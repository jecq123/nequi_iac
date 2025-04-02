output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
