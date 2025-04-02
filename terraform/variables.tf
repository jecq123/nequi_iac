variable "db_username" {}
variable "db_password" {}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "db_name" {
  default = "nequi_franquicias_db"
}

variable "app_port" {
  default = 8080
}
