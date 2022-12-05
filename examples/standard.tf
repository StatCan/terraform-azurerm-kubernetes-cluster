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

  cluster_ssh_key = "ssh-rsa ArandomstuffhereEAw== ex-dev-cc-00"
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

# Manages a Managed Kubernetes Cluster
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
#
module "cluster" {
  source                    = "git::https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-azurerm-kubernetes-cluster.git?ref=main"
  prefix                    = local.prefix
  location                  = "Canada Central"
  resource_group_name       = "ex_rg_name"
  user_assigned_identity_id = "1234"
  ssh_key                   = local.cluster_ssh_key

  tags                        = local.azure_tags
  default_node_pool_subnet_id = "123.34.5.6"
}
