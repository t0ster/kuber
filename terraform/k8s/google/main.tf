resource "google_container_cluster" "primary" {
  name     = "primary"
  location = "europe-west2-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  master_auth {
    username = "admin"
    password = "B.1#9891!1019C91d1m"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary" {
  name       = "node-pool-1"
  location = "europe-west2-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "n1-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  provisioner "local-exec" {
    command = "echo You need to manually add firewall rule to default network to allow HTTP\\(S\\) traffic"
  }
}

data "google_compute_network" "default" {
  name = "default"
}

# resource "google_compute_firewall" "default" {
#   name    = "default"
#   network = "default"
# }

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}
output "master_auth" {
  value = google_container_cluster.primary.master_auth
}
