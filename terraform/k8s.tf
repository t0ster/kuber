variable "project" {
  type = string
  default = ""
}

provider "google" {
  credentials = file("google-account.json")
  project     = var.project
}

module "k8s" {
  source = "./k8s/google"
}

provider "kubernetes" {
  host     = "https://${module.k8s.endpoint}"
  username = module.k8s.master_auth[0].username
  password = module.k8s.master_auth[0].password

  cluster_ca_certificate = base64decode(module.k8s.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    namespace = "kube-system"
    name = "tiller"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = "kube-system"
  }
}

provider "helm" {
  kubernetes {
    host     = "https://${module.k8s.endpoint}"
    username = module.k8s.master_auth[0].username
    password = module.k8s.master_auth[0].password

    cluster_ca_certificate = base64decode(module.k8s.master_auth[0].cluster_ca_certificate)
  }

  service_account = kubernetes_service_account.tiller.metadata[0].name
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.16.1"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "ingress" {
  depends_on = [kubernetes_cluster_role_binding.tiller]
  name       = "ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "nginx-ingress"
  # version    = "6.0.1"

  namespace = "ingress"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set_string {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.daemonset.useHostPort"
    value = "true"
  }

  set {
    name = "controller.service.enabled"
    value = "false"
  }
}
