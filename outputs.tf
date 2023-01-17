##################
### OS Profile ###
##################

output "linux_username" {
  description = "The Admin Username for the Cluster."
  value       = random_pet.linux_username.id
}

output "windows_username" {
  description = "The Admin Username for Windows VMs."
  value       = random_pet.windows_username.id
}

output "windows_password" {
  description = "The Admin Password for Windows VMs."
  value       = random_password.windows_password.result
}

###################
### AKS Cluster ###
###################

output "kubernetes_cluster_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.cluster.id
}

output "admin_kubeconfig" {
  description = "A Terraform object that contain kubeconfig info. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = var.local_account_disabled == false ? azurerm_kubernetes_cluster.cluster.kube_admin_config : null
}

output "node_resource_group_name" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster.fqdn
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
}

output "kubernetes_identity" {
  description = "The managed service identity assigned to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.cluster.identity
}

output "kubernetes_kubelet_identity" {
  description = "The user-defined Managed Identity assigned to the Kubelets."
  value       = var.kubelet_identity
}
