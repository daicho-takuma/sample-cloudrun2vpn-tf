#########################
# Compute Engine
#########################
resource "google_compute_instance" "vms" {
  for_each     = local.gcp_instance_config
  name         = each.key
  machine_type = each.value.type
  zone         = each.value.zone
  #deletion_protection = each.value.protected
  boot_disk {
    initialize_params {
      size  = each.value.vol_size
      type  = each.value.vol_type
      image = data.google_compute_image.debian12_image.self_link
    }
  }

  network_interface {
    subnetwork = each.value.subnet_name
    network_ip = each.value.private_ip
    # access_config {}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.vms[each.key].email
    scopes = ["cloud-platform"]
  }
}

# ----------------------
# Compute Engine Image
# ----------------------
data "google_compute_image" "debian12_image" {
  family  = "debian-12"
  project = "debian-cloud"
}

# ----------------------
# Service Account
# ----------------------
resource "google_service_account" "vms" {
  for_each     = local.gcp_instance_config
  account_id   = "${each.key}-sa"
  display_name = "Custom SA for VM Instance form ${each.key}"
}
