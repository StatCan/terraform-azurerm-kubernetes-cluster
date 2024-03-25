locals {
  cluster_ssh_key = "ssh-rsa ArandomstuffhereEAw== ex-dev-cc-00"
}

#####################
### Prerequisites ###
#####################

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Canada Central"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "system"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "apiserver"
    address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.canadacentral.azmk8s.io"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks"
  resource_group_name = azurerm_resource_group.example.name
  location            = "Canada Central"
}

resource "azurerm_role_assignment" "aks_msi_vnet" {
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = azurerm_virtual_network.example.id
}

resource "azurerm_role_assignment" "aks_msi_dns_zone" {
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = azurerm_private_dns_zone.example.id
}

#################################
### Kubernetes Cluster Module ###
#################################

# Manages a Managed Kubernetes Cluster.
#
# https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-azure-kubernetes-cluster
#
module "cluster" {
  source = "../../"

  azure_resource_attributes = {
    project     = "cns"
    environment = "dev"
    location    = azurerm_resource_group.example.location
    instance    = 0
  }
  resource_group_name = azurerm_resource_group.example.name

  kubernetes_version = null

  # Identity / RBAC
  user_assigned_identity_ids   = [azurerm_user_assigned_identity.aks.id]
  linux_profile_public_ssh_key = local.cluster_ssh_key

  # Networking
  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.example.id
  dns_prefix              = "cns-dev-cc-00"
  api_server = {
    subnet_id                = azurerm_virtual_network.example.subnet.*.id[1]
    vnet_integration_enabled = true
  }

  network_plugin = "none"
  network_policy = null
  network_mode   = null

  service_cidr   = "12.0.0.0/16"
  dns_service_ip = "12.0.0.10"

  # System Node Pool
  default_node_pool = {
    vnet_subnet_id         = azurerm_virtual_network.example.subnet.*.id[0]
    node_count             = 1
    kubernetes_version     = null
    availability_zones     = [1, 2, 3]
    vm_size                = "Standard_D2s_v3"
    node_labels            = {}
    node_taints            = []
    max_pods               = 60
    enable_host_encryption = false
    os_disk_size_gb        = 256
    os_disk_type           = "Managed"
    os_type                = "Linux"
    upgrade_max_surge      = "33%"
    enable_auto_scaling    = false
  }

  maintenance_window_node_os = {
    frequency   = "Weekly"
    interval    = 1
    day_of_week = "Tuesday"

    start_time = "22:00"
    duration   = 4
  }
}
