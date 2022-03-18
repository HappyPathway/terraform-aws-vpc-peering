# generally, these blocks would be in a different module
data "vault_aws_access_credentials" "requester" {
  backend = "AWS::${var.requester}"
  role    = "admin"
}

data "vault_aws_access_credentials" "accepter" {
  backend = "AWS::${var.accepter}"
  role    = "admin"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.requester.access_key}"
  secret_key = "${data.vault_aws_access_credentials.requester.secret_key}"
  alias = "requester"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.accepter.access_key}"
  secret_key = "${data.vault_aws_access_credentials.accepter.secret_key}"
  alias = "accepter"
}

data "aws_caller_identity" "requester" {
  provider = "aws.requester"
}

data "aws_caller_identity" "accepter" {
  provider = "aws.accepter"
}

resource "aws_vpc_peering_connection" "requester" {
  provider      = "aws.requester"
  peer_owner_id = "${data.aws_caller_identity.accepter.account_id}"
  peer_vpc_id   = "${var.accepter_vpc_id}"
  vpc_id        = "${var.requester_vpc_id}"
  auto_accept   = true
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = "aws.accepter"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
  auto_accept               = true
}


# Create a route
resource "aws_route" "requester_r" {
  provider                  = "aws.requester"
  route_table_id            = "${var.requester_route_table_id}"
  destination_cidr_block    = "${var.requester_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
}


# Create a route
resource "aws_route" "accepter_r" {
  provider      = "aws.accepter"
  route_table_id            = "${var.accepter_route_table_id}"
  destination_cidr_block    = "${var.accepter_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
}
