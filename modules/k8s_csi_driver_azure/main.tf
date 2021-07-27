resource "helm_release" "kv_azure_csi" {
  name       = "csi-secrets-provider-azure"
  repository = var.repository
  chart      = "csi-secrets-store-provider-azure"
  version    = var.csi_provider_version
  # In which K8S namespace the Azure provider for CSI driver should be installed.
  # TODO: Should this be the same namespace as where the actual application is deployed.
  # namespace = var.namespace
  # create_namespace = true
}
