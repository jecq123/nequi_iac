provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = ">= 1.0"
}

module "vpc" {
  source = "./vpc.tf"
}

module "security_groups" {
  source = "./security_groups.tf"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source               = "./rds.tf"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  security_group_id    = module.security_groups.db_sg_id
}

module "ecs" {
  source            = "./ecs.tf"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.ecs_sg_id
}

module "ecr" {
  source = "./ecr.tf"
}
