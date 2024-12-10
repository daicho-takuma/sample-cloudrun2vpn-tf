resource "google_compute_network" "vpc" {
  name                    = local.gcp_network_config.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = local.gcp_network_config.general_subnet
  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "proxy_subnet" {
  for_each      = local.gcp_network_config.proxy_subnet
  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_firewall" "icmp" {
  name    = "${local.env}-${local.project}-gcp-vpc-fw-allow-icmp-all"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${local.env}-${local.project}-gcp-vpc-fw-allow-ssh-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "http_health_check" {
  name      = "${local.env}-${local.project}-gcp-vpc-fw-allow-http-health-check"
  direction = "INGRESS"
  network   = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

