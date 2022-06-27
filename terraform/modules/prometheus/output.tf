output "namespace" {
  value = kubernetes_namespace.prometheus_namespace.metadata[0].name
}
