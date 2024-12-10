#########################
# Site-to-site VPN
#########################

# ----------------------
# Virtual Private Gateway
# ----------------------
resource "aws_vpn_gateway" "vgw" {
  vpc_id          = aws_vpc.vpc.id
  amazon_side_asn = local.aws_vpn_config.asn
  tags = {
    Name = "${local.env}-${local.project}-vgw"
  }
}

# Propagation of route table
resource "aws_vpn_gateway_route_propagation" "vgw_propagate_public" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpn_gateway_route_propagation" "vgw_propagate_private" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.private.id
}

# ----------------------
# Customer Gateway
# ----------------------
resource "aws_customer_gateway" "cgw_01" {
  bgp_asn    = local.gcp_vpn_config.asn
  ip_address = google_compute_ha_vpn_gateway.vpn_gw.vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "${local.env}-${local.project}-cgw-01"
  }
}

resource "aws_customer_gateway" "cgw_02" {
  bgp_asn    = local.gcp_vpn_config.asn
  ip_address = google_compute_ha_vpn_gateway.vpn_gw.vpn_interfaces[1].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "${local.env}-${local.project}-cgw-02"
  }
}

# ----------------------
# Site-to-site connection
# ----------------------
resource "aws_vpn_connection" "vpn_connection_01" {
  vpn_gateway_id           = aws_vpn_gateway.vgw.id
  customer_gateway_id      = aws_customer_gateway.cgw_01.id
  type                     = "ipsec.1"
  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"
  tags = {
    Name = "${local.env}-${local.project}-connection-01"
  }
}

resource "aws_vpn_connection" "vpn_connection_02" {
  vpn_gateway_id           = aws_vpn_gateway.vgw.id
  customer_gateway_id      = aws_customer_gateway.cgw_02.id
  type                     = "ipsec.1"
  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"
  tags = {
    Name = "${local.env}-${local.project}-connection-02"
  }
}
