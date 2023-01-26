variable "project" {
  type    = string
  default = ""
}

variable "tags" {
  type = map
  default = {}
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "vpc_id" {
  type    = string
  default = ""
}
variable "subnet_id" {
  type    = string
  default = ""
}

variable "gateway_image_url" {
  type    = string
  default = ""
}

variable "server_image_url" {
  type    = string
  default = ""
}

variable "ops_image_url" {
  type    = string
  default = ""
}

variable "log_group_name" {
  type    = string
  default = ""
}
variable "lb_target_group_arn" {
  type    = string
  default = ""
}

variable "db_instance_address" {
  type    = string
  default = ""
}

variable "db_security_group_id" {
  type    = string
  default = ""
}

variable "redis_security_group_id" {
  type    = string
  default = ""
}

variable "redis_host" {
  type    = string
  default = ""
}

variable "path_to_encryption_key" {
  type    = string
  default = ""
}

variable "config_bucket_name" {
  type    = string
  default = ""
}

variable "filestore_bucket_name" {
  type    = string
  default = ""
}

