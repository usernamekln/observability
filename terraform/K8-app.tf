resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo-app"
  }
}

resource "kubernetes_manifest" "app_files" {
  for_each = fileset("${path.module}/../k8s", "*.yaml")

  manifest = yamldecode(file("${path.module}/../k8s/${each.value}"))
}
