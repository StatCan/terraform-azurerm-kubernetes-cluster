# terraform-azurerm-kubernetes-cluster

This module deploys an Azure Kubernetes Service (AKS) cluster.

## Usage

Examples for this module along with various configurations can be found in the [examples/](examples/) folder.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.15, < 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.15, < 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [random_password.windows_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.linux_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.windows_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | Group object IDs for groups receiving administrative access to the cluster | `list(string)` | `[]` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | List of IP ranges authorized to reach the API server | `list(string)` | `[]` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | Automatically perform upgrades of the Kubernetes cluster (none, patch, rapid, stable) | `string` | `"none"` | no |
| <a name="input_default_node_pool_auto_scaling_max_nodes"></a> [default\_node\_pool\_auto\_scaling\_max\_nodes](#input\_default\_node\_pool\_auto\_scaling\_max\_nodes) | Maximum number of nodes in the default node pool, when auto scaling is enabled | `number` | `5` | no |
| <a name="input_default_node_pool_auto_scaling_min_nodes"></a> [default\_node\_pool\_auto\_scaling\_min\_nodes](#input\_default\_node\_pool\_auto\_scaling\_min\_nodes) | Minimum number of nodes in the default node pool, when auto scaling is enabled | `number` | `3` | no |
| <a name="input_default_node_pool_availability_zones"></a> [default\_node\_pool\_availability\_zones](#input\_default\_node\_pool\_availability\_zones) | Availability zones of the default node pool | `list(string)` | `null` | no |
| <a name="input_default_node_pool_critical_addons_only"></a> [default\_node\_pool\_critical\_addons\_only](#input\_default\_node\_pool\_critical\_addons\_only) | Only run critical addon pods in the default node pool | `bool` | `false` | no |
| <a name="input_default_node_pool_disk_size_gb"></a> [default\_node\_pool\_disk\_size\_gb](#input\_default\_node\_pool\_disk\_size\_gb) | Size, in GB, of the node disk in the default node pool | `number` | `256` | no |
| <a name="input_default_node_pool_disk_type"></a> [default\_node\_pool\_disk\_type](#input\_default\_node\_pool\_disk\_type) | Disk type of the default node pool (Managed or Ephemeral) | `string` | `"Managed"` | no |
| <a name="input_default_node_pool_enable_auto_scaling"></a> [default\_node\_pool\_enable\_auto\_scaling](#input\_default\_node\_pool\_enable\_auto\_scaling) | Enable auto scaling of the default node pool | `bool` | `false` | no |
| <a name="input_default_node_pool_enable_host_encryption"></a> [default\_node\_pool\_enable\_host\_encryption](#input\_default\_node\_pool\_enable\_host\_encryption) | Enable host encryption on the default node pool | `bool` | `false` | no |
| <a name="input_default_node_pool_kubernetes_version"></a> [default\_node\_pool\_kubernetes\_version](#input\_default\_node\_pool\_kubernetes\_version) | Kubernetes version of the default node pool (if unset, uses kubernetes\_version) | `any` | `null` | no |
| <a name="input_default_node_pool_labels"></a> [default\_node\_pool\_labels](#input\_default\_node\_pool\_labels) | Labels assigned to nodes in the default node pool | `map(string)` | `{}` | no |
| <a name="input_default_node_pool_max_pods"></a> [default\_node\_pool\_max\_pods](#input\_default\_node\_pool\_max\_pods) | Maximum number of pods per node in the default node pool | `number` | `60` | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | Name of the default node pool | `string` | `"system"` | no |
| <a name="input_default_node_pool_node_count"></a> [default\_node\_pool\_node\_count](#input\_default\_node\_pool\_node\_count) | Number of nodes in the default node pool | `number` | `3` | no |
| <a name="input_default_node_pool_subnet_id"></a> [default\_node\_pool\_subnet\_id](#input\_default\_node\_pool\_subnet\_id) | Subnet where to attach nodes in the default node pool | `any` | n/a | yes |
| <a name="input_default_node_pool_upgrade_max_surge"></a> [default\_node\_pool\_upgrade\_max\_surge](#input\_default\_node\_pool\_upgrade\_max\_surge) | Maximum node surge during a node pool upgrade | `string` | `"33%"` | no |
| <a name="input_default_node_pool_vm_size"></a> [default\_node\_pool\_vm\_size](#input\_default\_node\_pool\_vm\_size) | VM size of the default node pool | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | Disk Encryption Set ID for encryption cluster disks with Customer Managed Keys | `any` | `null` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP assigned to the cluster DNS service | `string` | `"10.0.0.10"` | no |
| <a name="input_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#input\_docker\_bridge\_cidr) | IP range to be used by the docker bridge | `string` | `"172.17.0.1/16"` | no |
| <a name="input_kubelet_identity_client_id"></a> [kubelet\_identity\_client\_id](#input\_kubelet\_identity\_client\_id) | The Client ID of the user-defined Managed Identity to be assigned to the Kubelets. | `string` | `null` | no |
| <a name="input_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#input\_kubelet\_identity\_object\_id) | The Object ID of the user-defined Managed Identity assigned to the Kubelets | `string` | `null` | no |
| <a name="input_kubelet_identity_user_assigned_identity_id"></a> [kubelet\_identity\_user\_assigned\_identity\_id](#input\_kubelet\_identity\_user\_assigned\_identity\_id) | The ID of the User Assigned Identity assigned to the Kubelets | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes specified when creating the AKS managed cluster | `string` | `"1.17.16"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where the Managed Kubernetes Cluster should be created. | `string` | `"Canada Central"` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | Network mode to use | `string` | `"transparent"` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin to use | `string` | `"azure"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy provider to use | `string` | `"azure"` | no |
| <a name="input_node_resource_group_name"></a> [node\_resource\_group\_name](#input\_node\_resource\_group\_name) | Name of the Resource Group where the Kubernetes Nodes should exist | `any` | `null` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable or Disable the OIDC issuer URL | `bool` | `true` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix used for the name of the cluster. | `string` | n/a | yes |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Deploy a private cluster control plane. Requires private link + private DNS support. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone id for use by private clusters. If unset, and a private cluster is requested, the DNS zone will be created and managed by AKS | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group where the Managed Kubernetes Cluster should exist | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | IP range to be used by the docker bridge | `string` | `"10.0.0.0/16"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU Tier of the cluster ("Paid" is preferred) | `string` | `"Free"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | SSH key for connecting to nodes | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags to assign to the Azure resources | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | Use Assigned Identity ID for use by the cluster control plane | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | n/a |
| <a name="output_kubernetes_identity"></a> [kubernetes\_identity](#output\_kubernetes\_identity) | n/a |
| <a name="output_linux_username"></a> [linux\_username](#output\_linux\_username) | n/a |
| <a name="output_node_resource_group_name"></a> [node\_resource\_group\_name](#output\_node\_resource\_group\_name) | n/a |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | n/a |
| <a name="output_windows_password"></a> [windows\_password](#output\_windows\_password) | n/a |
| <a name="output_windows_username"></a> [windows\_username](#output\_windows\_username) | n/a |
<!-- END_TF_DOCS -->

## History

| Date       | Release | Change         |
| ---------- | ------- | -------------- |
| 2022-11-22 | v2.0.0  | initial commit |
