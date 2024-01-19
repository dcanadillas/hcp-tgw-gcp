data "google_compute_subnetwork" "network_subnet1" {
  depends_on = [ google_compute_subnetwork.network_subnet1 ]
  self_link   = google_compute_subnetwork.network_subnet1.self_link
}
data "google_compute_subnetwork" "network_subnet2" {
  depends_on = [ google_compute_subnetwork.network_subnet2 ]
  self_link   = google_compute_subnetwork.network_subnet2.self_link
}


resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  region   = var.gcp_region
  name     = "gcp-vpn-to-aws"
  network  = google_compute_network.network.id
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "cgw-in-aws"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = aws_vpn_connection.example.tunnel1_address
  }
}

resource "google_compute_network" "network" {
  name                    = "network-1"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network_subnet1" {
  name          = "ha-vpn-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.network.id
}

resource "google_compute_subnetwork" "network_subnet2" {
  name          = "ha-vpn-subnet-2"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.network.id
}

resource "google_compute_router" "router1" {
  name     = "gcp-default-cr"
  network  = google_compute_network.network.name
  bgp {
    asn = 65100
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "aws-vpn-tunnel-1"
  region                          = var.gcp_region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = aws_vpn_connection.example.tunnel1_preshared_key
  router                          = google_compute_router.router1.id
  vpn_gateway_interface           = 0
}

resource "google_compute_router_peer" "peer" {
  name                      = "aws-bgp-peer"
  router                    = google_compute_router.router1.name
  region                    = var.gcp_region
  peer_asn                  = 64512
  interface                 = google_compute_router_interface.router1_interface1.name
  peer_ip_address = aws_vpn_connection.example.tunnel1_vgw_inside_address
}

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.router1.name
  region     = var.gcp_region
  ip_range   = "${aws_vpn_connection.example.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}



