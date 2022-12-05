output "linux_username" {
  value = random_pet.linux_username.id
}

output "windows_username" {
  value = random_pet.windows_username.id
}

output "windows_password" {
  value = random_password.windows_password.result
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config
}

output "node_resource_group_name" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "kubernetes_identity" {
  value = azurerm_kubernetes_cluster.cluster.kubelet_identity
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.cluster.fqdn
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
}
