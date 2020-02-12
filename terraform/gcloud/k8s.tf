variable "letsencrypt_email" {}
variable "password" {}
variable "project" {
  type = string
  default = ""
}

provider "google" {
  credentials = file("google-account.json")
  project     = var.project
}

module "k8s" {
  source = "../modules/k8s/google"
  letsencrypt_email = var.letsencrypt_email
  flux_values_file = "${path.root}/flux-values.yaml"
  password = var.password
}


# provider "kubernetes" {
#   load_config_file = false
#   host     = "https://${module.k8s.endpoint}"
#   username = module.k8s.master_auth[0].username
#   password = module.k8s.master_auth[0].password
#
#   cluster_ca_certificate = base64decode(module.k8s.master_auth[0].cluster_ca_certificate)
# }

# resource "kubernetes_service_account" "tiller" {
#   metadata {
#     namespace = "kube-system"
#     name = "tiller"
#   }
#   automount_service_account_token = true
# }

# resource "kubernetes_cluster_role_binding" "tiller" {
#   metadata {
#     name = "tiller"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.tiller.metadata[0].name
#     namespace = "kube-system"
#   }
# }

# provider "helm" {
#   kubernetes {
#     load_config_file = false
#     host     = "https://${module.k8s.endpoint}"
#     username = module.k8s.master_auth[0].username
#     password = module.k8s.master_auth[0].password
#
#     cluster_ca_certificate = base64decode(module.k8s.master_auth[0].cluster_ca_certificate)
#   }
#
#   # service_account = kubernetes_service_account.tiller.metadata[0].name
#   # tiller_image = "gcr.io/kubernetes-helm/tiller:v2.16.1"
# }

# data "helm_repository" "stable" {
#   name = "stable"
#   url  = "https://kubernetes-charts.storage.googleapis.com"
# }
#
# resource "kubernetes_namespace" "ingress" {
#   metadata {
#     name = "ingress"
#   }
# }
#
# resource "helm_release" "ingress" {
#   # depends_on = [kubernetes_cluster_role_binding.tiller]
#   name       = kubernetes_namespace.ingress.metadata[0].name
#   repository = data.helm_repository.stable.metadata[0].name
#   chart      = "nginx-ingress"
#   # version    = "6.0.1"
#
#   namespace = "ingress"
#
#   set {
#     name  = "rbac.create"
#     value = "true"
#   }
#
#   set_string {
#     name  = "controller.kind"
#     value = "DaemonSet"
#   }
#
#   set {
#     name  = "controller.daemonset.useHostPort"
#     value = "true"
#   }
#
#   set {
#     name = "controller.service.enabled"
#     value = "false"
#   }
# }

# data "helm_repository" "fluxcd" {
#   name = "fluxcd"
#   url  = "https://charts.fluxcd.io"
# }

# resource "kubernetes_namespace" "flux" {
#   metadata {
#     name = "flux"
#   }
# }
#
# resource "helm_release" "example" {
#   name       = "my-redis-release"
#   repository = data.helm_repository.fluxcd.metadata[0].name
#   chart      = "helm-operator"
#
#   values = [
#     "${file("values.yaml")}"
#   ]
#
#   set {
#     name  = "cluster.enabled"
#     value = "true"
#   }
#
#   set {
#     name  = "metrics.enabled"
#     value = "true"
#   }
#
#   set_string {
#     name  = "service.annotations.prometheus\\.io/port"
#     value = "9127"
#   }
# }
