locals {
  prefix = "dev"

  azure_tags = {
    DataClassification      = "Undefined"
    wid                     = 900033
    Metadata                = "Undefined"
    environment             = "dev"
    PrimaryTechnicalContact = "william.hearn@statcan.gc.ca"
    PrimaryProjectContact   = "zachary.seguin@statcan.gc.ca"
  }
}

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

  prefix                     = local.prefix
  location                   = "Canada Central"
  resource_group_name        = "ex_rg_name"
  user_assigned_identity_ids = ["1234"]

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

  tags = local.azure_tags
}
