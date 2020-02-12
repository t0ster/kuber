variable "letsencrypt_email" {}

resource "digitalocean_kubernetes_cluster" "default" {
  name    = "default"
  region  = "sfo2"
  version = "1.16.6-do.0"

  node_pool {
    name       = "pool-main"
    size       = "s-1vcpu-2gb"
    node_count = 1
  }
}

resource "digitalocean_firewall" "web" {
  name = "k8s-worker"

  tags = ["k8s:worker"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}

module "k8s" {
  source = "../core"
  k8s_provider = "do"
  cluster = digitalocean_kubernetes_cluster.default
  letsencrypt_email = var.letsencrypt_email
}
