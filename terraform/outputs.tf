output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "ecr_repo_url" {
  value = module.ecr.ecr_repo_url
}
