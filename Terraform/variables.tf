variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}
variable "private_subnetA_cidr" {
  description = "The CIDR block for private subnet A."
  type        = string
}
variable "private_subnetB_cidr" {
  description = "The CIDR block for private subnet B."
  type        = string
}
variable "public_subnetA_cidr" {
  description = "The CIDR block for public subnet A."
  type        = string
}
variable "public_subnetB_cidr" {
  description = "The CIDR block for public subnet B."
  type        = string
}

