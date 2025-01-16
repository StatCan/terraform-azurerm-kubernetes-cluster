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

resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
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

  # Diagnostic Settings
  diag_setting = {
    "law_logs" = {
      log_analytics_workspace_id     = azurerm_log_analytics_workspace.example.id
      log_analytics_destination_type = "Dedicated"
      enabled_log_categories         = ["kube-apiserver", "kube-controller-manager"]
      enable_all_metrics             = true
    }
  }
}
