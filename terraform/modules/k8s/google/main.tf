variable "letsencrypt_email" {}
variable "flux_values_file" {}
variable "password" {}

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
    password = var.password

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

resource "google_container_node_pool" "pool_2" {
  name       = "node-pool-2"
  location = "europe-west2-a"
  cluster    = google_container_cluster.primary.name
  initial_node_count = 0
  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"
    taint = [
      {
        key    = "preemptible"
        value  = true
        effect = "NO_SCHEDULE"
      }
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# data "google_compute_network" "default" {
#   name = "default"
# }

# resource "google_compute_firewall" "default" {
#   name    = "default"
#   network = "default"
# }

# output "endpoint" {
#   value = google_container_cluster.primary.endpoint
# }
# output "master_auth" {
#   value = google_container_cluster.primary.master_auth
# }

provider "kubernetes" {
  load_config_file = false
  host     = "https://${google_container_cluster.primary.endpoint}"
  username = google_container_cluster.primary.master_auth[0].username
  password = google_container_cluster.primary.master_auth[0].password

  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file = false
    host     = "https://${google_container_cluster.primary.endpoint}"
    username = google_container_cluster.primary.master_auth[0].username
    password = google_container_cluster.primary.master_auth[0].password

    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }

  # service_account = kubernetes_service_account.tiller.metadata[0].name
  # tiller_image = "gcr.io/kubernetes-helm/tiller:v2.16.1"
}

resource "local_file" "kube_config" {
  content = templatefile("${path.module}/kubeconfig.yaml.tmpl", { cluster = google_container_cluster.primary, k8s_provider = "gke" })
  filename = "${path.root}/k8s-config.yml"
}

module "k8s" {
  source = "../core"
  k8s_provider = "gke"
  # cluster = digitalocean_kubernetes_cluster.default
  letsencrypt_email = var.letsencrypt_email
  kube_config_file = local_file.kube_config.filename
  flux_values_file = var.flux_values_file
  # providers = {
  #   kubernetes = kubernetes
  #   helm = helm
  # }
}
