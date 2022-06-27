variable "vpce_vpc_id" {
  type        = string
  description = "VPCE VPC id"
}

variable "vpce_vpc_cidr" {
  type        = string
  description = "VPCE VPC cide"
}

variable "vpce_subnet_ids" {
  type        = list(string)
  description = "VPCE subnet id list"
  default     = []
}