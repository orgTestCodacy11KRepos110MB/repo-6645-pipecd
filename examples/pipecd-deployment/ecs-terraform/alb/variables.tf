variable "project" {
  type    = string
  default = ""
}

variable "tags" {
  type = map
  default = {}
}
variable "vpc_id" {
  type    = string
  default = ""
}
variable "subnet_ids" {
  type    = list
  default = []
}