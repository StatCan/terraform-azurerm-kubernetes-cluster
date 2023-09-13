# Azure Kubernetes Service (AKS) Cluster

## Introduction

This module deploys an Azure Kubernetes Service (AKS) cluster.

## Security Controls

This module is not sufficient on its own to meet the necessary security controls required
by the Government of Canada. It provides a framework for implementing the controls that
are determined by your organization's Security Assessment & Authorization (SA&A) process.

## Dependencies

* An Azure resource group to place the cluster
* An account with sufficient permissions to create AKS resources
* A User Assigned Identity for use by the cluster control plane

### Networking

Nodes in the cluster must be attached to an existing subnet within an Azure Virtual Network.
The subnet **must** have a Network Virtual Appliance at the default route (ie. `0.0.0.0/0`). See the [Azure documentation on egress](https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype#outbound-type-of-userdefinedrouting) for more information. This can be an Azure Firewall or a virtual appliance performing firewall/routing functions.

Ensure your virtual network IP space does not overlap with the subnets defined in the [Azure CNI prerequisites](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#prerequisites).

## Optional (depending on options configured):

* None

## Usage

```terraform
module "cluster" {
  source = "git::https://github.com/canada-ca-terraform-modules/terraform-azurerm-kubernetes-cluster.git?ref=$REF"

  # ... your variable values
}
```

## Variables Values

| Name                                     | Type         | Required | Value                                                                                                                                            |
| ---------------------------------------- | ------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| prefix                                   | string       | yes      | Prefix for Azure resources created by the module                                                                                                 |
| resource_group_name                      | string       | yes      | Name of the Azure resource group to deploy Azure resources                                                                                       |
| node_resource_group_name                 | string       | no       | Name of the Azure resource group created by the cluster. This resource group must not already exist. If unset, Azure will generate a random name |
| location                                 | string       | yes      | Azure region where to deploy the Azure resources                                                                                                 |
| kubernetes_version                       | string       | no       | Version of Kubernetes to deploy                                                                                                                  |
| automatic_channel_upgrade                | string       | no       | Automatically perform upgrades of the Kubernetes cluster (none, patch, rapid, stable)                                                            |
| api_server_authorized_ip_ranges          | list(string) | no       | List of IP ranges authorized to reach the API server                                                                                             |
| private_cluster_enabled                  | bool         | no       | Deploy a private control plane                                                                                                                   |
| private_dns_zone_id                      | bool         | no       | Use the provided private DNS zone instead of an AKS managed private DNS zone                                                                     |
| user_assigned_identity_id                | string       | yes      | User Assigned Identity ID for use by the cluster control plane                                                                                   |
| sku_tier                                 | string       | no       | SKU Tier for use by the cluster ("Paid" is preferred)                                                                                            |
| disk_encrpytion_set_id                   | string       | no       | Disk Encryption Set ID for encryption cluster disks with Customer Managed Keys                                                                   |
| admin_group_object_ids                   | list(string) | no       | List of group IDs to receive administrative access to the cluster                                                                                |
| default_node_pool_name                   | string       | no       | Name of the default node pool                                                                                                                    |
| default_node_pool_node_count             | number       | no       | Number of nodes in the default node pool                                                                                                         |
| default_node_pool_kubernetes_version     | string       | no       | Kubernetes version of the default node pool (if unset, uses kubernetes_version)                                                                  |
| default_node_pool_availability_zones     | list(string) | no       | List of availability zones for the default node pool                                                                                             |
| default_node_pool_vm_size                | string       | no       | VM size of the default node pool                                                                                                                 |
| default_node_pool_labels                 | map(string)  | no       | List of labels to assign to nodes in the default node pool                                                                                       |
| default_node_pool_enable_host_encryption | bool         | no       | Enable host encryption in the default node pool                                                                                                  |
| default_node_pool_disk_size_gb           | number       | no       | Size of the node disk size of the default node pool                                                                                              |
| default_node_pool_disk_type              | string       | no       | Type of disk used by the default node pool (Managed, Ephemeral)                                                                                  |
| default_node_pool_subnet_id              | string       | yes      | Subnet where to attach nodes in the default node pool                                                                                            |
| default_node_pool_critical_addons_only   | bool         | no       | Only run critical addon pods in the default node pool                                                                                            |
| default_node_pool_upgrade_max_surge      | string       | no       | Maximum node surge during a node pool upgrade                                                                                                    |
| ssh_key                                  | string       | yes      | SSH public key for accessing node virtual machines                                                                                               |
| tags                                     | map(string)  | no       | Azure tags to assign to Azure resources                                                                                                          |

## History

| Date       | Release | Change                                        |
| ---------- | ------- | --------------------------------------------- |
| 2023-09-11 | 1.0.4   | Backport tagging strategy for Azure resources |
| 2023-07-31 | 1.0.3   | Fix load_balancer_sku case                    |
| 2023-07-31 | 1.0.2   | Leverage AKS managed blob-csi driver          |
| 2022-03-24 | 1.0.1   | Add standard files for open sourcing          |
| 2021-07-06 | 1.0.0   | Initial release                               |
