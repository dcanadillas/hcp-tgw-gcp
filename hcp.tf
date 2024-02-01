
data "hcp_consul_cluster" "example" {
  count = var.consul_cluster != "" ? 1 : 0
  cluster_id = var.consul_cluster
}

data "hcp_vault_cluster" "example" {
  count = var.vault_cluster != "" ? 1 : 0
  cluster_id = var.vault_cluster
}

resource "aws_ram_resource_share" "example" {
  name                      = "dc-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  principal          = data.hcp_hvn.main.provider_account_id
}

resource "aws_ram_resource_association" "example" {
  resource_share_arn = aws_ram_resource_share.example.arn
  resource_arn       = aws_ec2_transit_gateway.example.arn
}

resource "hcp_aws_transit_gateway_attachment" "example" {
  depends_on = [
    aws_ram_principal_association.example,
    aws_ram_resource_association.example,
  ]

  hvn_id                        = data.hcp_hvn.main.hvn_id
  transit_gateway_attachment_id = "dc-tgw-attachment"
  transit_gateway_id            = aws_ec2_transit_gateway.example.id
  resource_share_arn            = aws_ram_resource_share.example.arn
}

resource "hcp_hvn_route" "route" {
  hvn_link         = data.hcp_hvn.main.self_link
  hvn_route_id     = "hvn-to-tgw-attachment"
  # destination_cidr = data.aws_vpc.selected.cidr_block
  destination_cidr = google_compute_subnetwork.network_subnet1.ip_cidr_range
  target_link      = hcp_aws_transit_gateway_attachment.example.self_link
}

# GCP subnets can have a secondary range of IPs (For example if a GKE cluster is deployed later in that subnet). This is the secondary range for the subnet
resource "hcp_hvn_route" "secondary_routes" {
  depends_on = [ data.google_compute_subnetwork.network_subnet1 ]
  # for_each = local.secondary_ranges
  count = var.secondary_ranges ? length(data.google_compute_subnetwork.network_subnet1.secondary_ip_range) : 0
  hvn_link         = data.hcp_hvn.main.self_link
  hvn_route_id     = "hvn-to-tgw-attachment-sec${count.index}"
  # destination_cidr = data.aws_vpc.selected.cidr_block
  destination_cidr = data.google_compute_subnetwork.network_subnet1.secondary_ip_range[count.index].ip_cidr_range
  target_link      = hcp_aws_transit_gateway_attachment.example.self_link
}

resource "hcp_hvn_route" "secondary_routes2" {
  depends_on = [ data.google_compute_subnetwork.network_subnet2 ]
  count = var.secondary_ranges ? length(data.google_compute_subnetwork.network_subnet2.secondary_ip_range) : 0
  hvn_link         = data.hcp_hvn.main.self_link
  hvn_route_id     = "hvn-to-tgw-attachment-sec${count.index}"
  # destination_cidr = data.aws_vpc.selected.cidr_block
  destination_cidr = data.google_compute_subnetwork.network_subnet2.secondary_ip_range[count.index].ip_cidr_range
  target_link      = hcp_aws_transit_gateway_attachment.example.self_link
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "example" {
  transit_gateway_attachment_id = hcp_aws_transit_gateway_attachment.example.provider_transit_gateway_attachment_id
}