variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "ingress_ports" {
  description = "List of ports to allow inbound traffic on the ALB security group"
  type        = list(number)
  default     = [80]
}
