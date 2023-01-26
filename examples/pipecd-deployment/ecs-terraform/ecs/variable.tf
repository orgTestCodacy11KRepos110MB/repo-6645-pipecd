variable "project" {

}

variable "tags" {

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

}

variable "db_security_group_id" {

}

variable "redis_security_group_id" {

}

variable "redis_host" {

}

variable "path_to_encryption_key" {

}

variable "config_bucket_name" {

}

variable "filestore_bucket_name" {

}

