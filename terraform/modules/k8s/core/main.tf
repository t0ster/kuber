variable "k8s_provider" {}
variable "letsencrypt_email" {}
variable "kube_config_file" {}
variable "flux_values_file" {}
# variable "cluster" {
#   type = object({
#     name = string
#     endpoint    = string
#     kube_config = list(object({
#       token = string
#       cluster_ca_certificate = string
#     }))
#   })
# }

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "nginx-ingress"

  namespace = kubernetes_namespace.ingress.metadata[0].name

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


data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart      = "cert-manager"
  version    = "v0.11.1"
  depends_on = [
    null_resource.crds,
  ]

  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  set_string {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }
  set_string {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set_string {
    name  = "ingressShim.defaultIssuerGroup"
    value = "cert-manager.io"
  }
}


data "helm_repository" "fluxcd" {
  name = "fluxcd"
  url  = "https://charts.fluxcd.io"
}
resource "kubernetes_namespace" "flux" {
  metadata {
    name = "flux"
  }
}
resource "helm_release" "flux" {
  name       = "flux"
  repository = data.helm_repository.fluxcd.metadata[0].name
  chart      = "flux"
  depends_on = [
    null_resource.crds,
  ]

  namespace = kubernetes_namespace.flux.metadata[0].name

  values = [
    file(var.flux_values_file)
  ]
}
resource "helm_release" "helm-operator" {
  name       = "helm-operator"
  repository = data.helm_repository.fluxcd.metadata[0].name
  chart      = "helm-operator"
  depends_on = [
    null_resource.crds,
  ]

  namespace = kubernetes_namespace.flux.metadata[0].name

  set_string {
    name  = "helm.versions"
    value = "v3"
  }
  set_string {
    name  = "git.ssh.secretName"
    value = "flux-git-deploy"
  }
}


resource "null_resource" "crds" {
    provisioner "local-exec" {
      environment = {
        KUBECONFIG = var.kube_config_file
      }
      command = <<-EOF
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml && \
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml && \
sleep 5 && \
sed -e "s/\$EMAIL/${var.letsencrypt_email}/" ${path.module}/letsencrypt-prod.yaml | kubectl apply -f -
EOF
  }
}
