#####################
### Prerequisites ###
#####################

provider "azurerm" {
  features {}
}

#################################
### Kubernetes Cluster Module ###
#################################

# Manages a Managed Kubernetes Cluster.
#
# https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-azure-kubernetes-cluster
#
module "cluster" {
  source = "../"

  azure_resource_attributes = {
    project     = "cns"
    environment = "dev"
    location    = azurerm_resource_group.example.location
    instance    = 0
  }

  resource_group_name = "ex_rg_name"

  # Identity / RBAC
  user_assigned_identity_ids = [azurerm_user_assigned_identity.aks.id]

  default_node_pool = {
    node_count             = 3
    kubernetes_version     = null
    availability_zones     = [1, 2, 3]
    vm_size                = "Standard_D16s_v3"
    node_labels            = {}
    node_taints            = []
    max_pods               = 60
    enable_host_encryption = false
    os_disk_size_gb        = 256
    os_disk_type           = "Managed"
    os_type                = "Linux"
    vnet_subnet_id         = ""
    upgrade_max_surge      = "33%"
    enable_auto_scaling    = false
    auto_scaling_min_nodes = 0
    auto_scaling_max_nodes = 3
  }
}
