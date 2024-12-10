#########################
# Cloud Run
#########################
resource "google_cloud_run_v2_service" "sample" {
  name                = "${local.env}-${local.project}-sample-run-app"
  description         = "Sample Cloud Run service"
  location            = local.gcp_network_config.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 80
    timeout                          = "300s"
    service_account                  = google_service_account.sample.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    vpc_access {
      network_interfaces {
        network    = google_compute_network.vpc.name
        subnetwork = google_compute_subnetwork.subnet["${local.env}-${local.project}-gcp-subnet-ane1"].name
      }
      egress = "ALL_TRAFFIC"
    }

    containers {
      image = data.google_artifact_registry_docker_image.sample.self_link

      ports {
        container_port = 8080
      }

      env {
        name  = "TARGET_IP"
        value = google_compute_address.ilb["${local.env}-${local.project}-gcp-ilb-proxy-subnet-ane1"].address
      }
    }
  }

  depends_on = [
    google_service_account.sample,
    google_artifact_registry_repository_iam_member.sample
  ]
}

#########################
# Service Account
#########################
resource "google_service_account" "sample" {
  account_id   = "${local.env}-sample-app-sa"
  display_name = "Sample App Service Account"
}

#########################
# Artifact Registry
#########################
data "google_artifact_registry_repository" "sample" {
  location      = local.gcp_network_config.region
  repository_id = "${local.env}-${local.project}-sample-app-repo"
}

data "google_artifact_registry_docker_image" "sample" {
  location      = local.gcp_network_config.region
  repository_id = data.google_artifact_registry_repository.sample.repository_id
  image_name    = "curl-golang:latest"
}

resource "google_artifact_registry_repository_iam_member" "sample" {
  location   = local.gcp_network_config.region
  repository = data.google_artifact_registry_docker_image.sample.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.sample.email}"
}
