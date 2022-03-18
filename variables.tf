variable "requester" {
    description = "AWS Account for VPC Requester"
}

variable "requester_vpc_id" {}
variable "requester_route_table_id" {}
variable "requester_vpc_cidr" {}

variable "accepter" {
    description = "AWS Account for VPC Accepter"
}

variable "accepter_vpc_id" {}
variable "accepter_route_table_id" {}
variable "accepter_vpc_cidr" {}

