output "kubernetes_cluster_id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.cluster.id
}

output "node_resource_group_name" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "node_resource_group_id" {
  description = "The ID of the Resource Group containing the resources for this Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.cluster.node_resource_group_id
}

##################
### OS Profile ###
##################

output "linux_username" {
  description = "The Admin Username for the Cluster."
  value       = random_pet.linux_username.id
}

output "linux_generated_private_ssh_key" {
  description = "The cluster will use this generated private key when `var.linux_profile_public_ssh_key` is null. Private key data in [PEM (RFC 1421)](https://datatracker.ietf.org/doc/html/rfc1421) format."
  sensitive   = true
  value       = var.linux_profile_public_ssh_key == null ? tls_private_key.ssh[0].private_key_pem : null
}

output "linux_generated_public_ssh_key" {
  description = "The cluster will use this generated public key as ssh key when `var.linux_profile_public_ssh_key` is empty or null."
  value       = var.linux_profile_public_ssh_key == null ? tls_private_key.ssh[0].public_key_openssh : null
}

output "windows_username" {
  description = "The Admin Username for Windows VMs."
  value       = random_pet.windows_username.id
}

output "windows_password" {
  description = "The Admin Password for Windows VMs."
  value       = random_password.windows_password.result
}

#######################
### Auth & Identity ###
#######################

output "kubeconfig" {
  description = "A Terraform object that contains kubeconfig info."
  value       = azurerm_kubernetes_cluster.cluster.kube_config
}

output "admin_kubeconfig" {
  description = "A Terraform object that contain kubeconfig info. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = var.local_account_disabled == false ? azurerm_kubernetes_cluster.cluster.kube_admin_config : null
}

output "kubernetes_identity" {
  description = "The managed service identity assigned to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.cluster.identity
}

output "kubernetes_kubelet_identity" {
  description = "The user-defined Managed Identity assigned to the Kubelets."
  value       = var.kubelet_identity
}

##################
### Networking ###
##################

output "fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster.fqdn
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = azurerm_kubernetes_cluster.cluster.oidc_issuer_url
}
