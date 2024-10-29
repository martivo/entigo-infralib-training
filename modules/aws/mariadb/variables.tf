variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_subnets" {
  type = list(string)
}

variable "database_subnet_group" {
  type = string
}

variable "instance_class" {
  type = string
  default = "db.t3.medium"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "max_allocated_storage" {
  type = number
  default = 40
}
