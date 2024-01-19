data "hcp_hvn" "main" {
  hvn_id = var.hvn_id
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_ec2_transit_gateway" "example" {
  description = "tgw-demo"
  tags = {
    Name = "tgw-for-hcp"
  }
  amazon_side_asn = 64512
  # auto_accept_shared_attachments = "enable"
}


resource "aws_customer_gateway" "main" {
  bgp_asn    = 65100
  ip_address = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "tgw-for-hcp"
  }
}

resource "aws_vpn_connection" "example" {
  customer_gateway_id = aws_customer_gateway.main.id
  transit_gateway_id  = aws_ec2_transit_gateway.example.id
  type                = aws_customer_gateway.main.type
}