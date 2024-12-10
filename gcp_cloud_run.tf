# data "google_project" "project" {}

resource "google_cloud_run_v2_service" "sample" {
  name                = "${local.env}-${local.project}-sample-run-app"
  description         = "Sample Cloud Run service"
  location            = local.gcp_network_config.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"
    max_instance_request_concurrency = 80
    timeout                          = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    vpc_access {
      network_interfaces {
        network    = google_compute_network.vpc.name
        subnetwork = google_compute_subnetwork.subnet["${local.env}-${local.project}-gcp-subnet-ane1"].name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      ports {
        container_port = 8080
      }
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}
