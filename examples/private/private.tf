locals {
  prefix = "dev"

  azure_tags = {
    DataClassification = "Undefined"
    wid                = 000000
    Metadata           = "Undefined"
    environment        = "dev"
  }

  cluster_ssh_key = "ssh-rsa ArandomstuffhereEAw== ex-dev-cc-00"
}

#####################
### Prerequisites ###
#####################

provider "azurerm" {
  features {}
}

module "network" {
  source = "git::https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-statcan-azure-cloud-native-environment-network?ref=v7.3.0"

  prefix   = local.prefix
  location = "Canada Central"

  vnet_address_space = ["10.0.0.0/21"]

  subnets = {
    RouteServerSubnet = {
      address_prefixes      = ["10.0.0.0/27"]
      create_nsg            = false
      associate_route_table = false
    }
    loadbalancer = {
      address_prefixes = ["10.0.0.32/27"]
    }
    gateway = {
      address_prefixes = ["10.0.0.64/27"]
    }
    system = {
      address_prefixes = ["10.0.0.128/27"]
    }
    general = {
      address_prefixes = ["10.0.1.0/25"]
    }
    infrastructure = {
      address_prefixes = ["10.0.0.96/27"]
    }
  }

  route_server_bgp_peers = []
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.canadacentral.azmk8s.io"
  resource_group_name = module.network.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks"
  resource_group_name = module.network.resource_group_name
  location            = "Canada Central"
}

resource "azurerm_role_assignment" "aks_msi_vnet" {
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = module.network.vnet_id
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

  prefix              = local.prefix
  location            = "Canada Central"
  resource_group_name = module.network.resource_group_name

  kubernetes_version = null

  # Identity / RBAC
  user_assigned_identity_ids = [azurerm_user_assigned_identity.aks.id]
  linux_profile_ssh_key      = local.cluster_ssh_key

  # Networking
  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.example.id
  dns_prefix              = local.prefix

  network_plugin = "none"
  network_policy = null
  network_mode   = null

  service_cidr   = "12.0.0.0/16"
  dns_service_ip = "12.0.0.10"

  # System Node Pool
  default_node_pool = {
    vnet_subnet_id         = module.network.vnet_subnets["system"].id
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

  tags = local.azure_tags
}
