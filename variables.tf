variable "prefix" {
  description = "The prefix used for the name of the cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Managed Kubernetes Cluster should exist"
  type        = string
  nullable    = false
}

variable "node_resource_group_name" {
  description = "Name of the Resource Group where the Kubernetes Nodes should exist"
  default     = null
}

variable "location" {
  description = "The location where the Managed Kubernetes Cluster should be created."
  type        = string
  nullable    = false
  default     = "Canada Central"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster"
  type        = string
  default     = "1.17.16"
}

variable "automatic_channel_upgrade" {
  description = "Automatically perform upgrades of the Kubernetes cluster (none, patch, rapid, stable)"
  type        = string
  default     = "none"
}

variable "api_server_authorized_ip_ranges" {
  description = "List of IP ranges authorized to reach the API server"
  type        = list(string)

  default = []
}

variable "private_cluster_enabled" {
  description = "Deploy a private cluster control plane. Requires private link + private DNS support."
  type        = bool

  default = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone id for use by private clusters. If unset, and a private cluster is requested, the DNS zone will be created and managed by AKS"
  type        = string

  default = null
}

variable "user_assigned_identity_id" {
  description = "Use Assigned Identity ID for use by the cluster control plane"
  type        = list(string)
}

variable "sku_tier" {
  description = "SKU Tier of the cluster (\"Paid\" is preferred)"
  type        = string

  default = "Free"
}

variable "disk_encryption_set_id" {
  description = "Disk Encryption Set ID for encryption cluster disks with Customer Managed Keys"

  default = null
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "Group object IDs for groups receiving administrative access to the cluster"

  default = []
}

variable "docker_bridge_cidr" {
  description = "IP range to be used by the docker bridge"

  default = "172.17.0.1/16"
}

variable "service_cidr" {
  description = "IP range to be used by the docker bridge"

  default = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP assigned to the cluster DNS service"

  default = "10.0.0.10"
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"

  default = "system"
}

variable "default_node_pool_node_count" {
  type        = number
  description = "Number of nodes in the default node pool"

  default = 3
}

variable "default_node_pool_enable_auto_scaling" {
  type        = bool
  description = "Enable auto scaling of the default node pool"

  default = false
}

variable "default_node_pool_auto_scaling_min_nodes" {
  type        = number
  description = "Minimum number of nodes in the default node pool, when auto scaling is enabled"

  default = 3
}

variable "default_node_pool_auto_scaling_max_nodes" {
  type        = number
  description = "Maximum number of nodes in the default node pool, when auto scaling is enabled"

  default = 5
}

variable "default_node_pool_kubernetes_version" {
  description = "Kubernetes version of the default node pool (if unset, uses kubernetes_version)"

  default = null
}

variable "default_node_pool_availability_zones" {
  type        = list(string)
  description = "Availability zones of the default node pool"

  default = null
}

variable "default_node_pool_vm_size" {
  description = "VM size of the default node pool"

  default = "Standard_D2s_v3"
}

variable "default_node_pool_max_pods" {
  description = "Maximum number of pods per node in the default node pool"

  default = 60
}

variable "default_node_pool_labels" {
  type        = map(string)
  description = "Labels assigned to nodes in the default node pool"

  default = {}
}

variable "default_node_pool_enable_host_encryption" {
  type        = bool
  description = "Enable host encryption on the default node pool"

  default = false
}

variable "default_node_pool_disk_size_gb" {
  type        = number
  description = "Size, in GB, of the node disk in the default node pool"

  default = 256
}

variable "default_node_pool_disk_type" {
  description = "Disk type of the default node pool (Managed or Ephemeral)"

  default = "Managed"
}

variable "default_node_pool_subnet_id" {
  description = "Subnet where to attach nodes in the default node pool"
}

variable "default_node_pool_critical_addons_only" {
  description = "Only run critical addon pods in the default node pool"

  default = false
}

# Per documentation, https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster#customize-node-surge-upgrade
#   > For production node pools, we recommend a max-surge setting of 33%.
variable "default_node_pool_upgrade_max_surge" {
  description = "Maximum node surge during a node pool upgrade"

  default = "33%"
}

variable "ssh_key" {
  description = "SSH key for connecting to nodes"
}

variable "tags" {
  type        = map(string)
  description = "Azure tags to assign to the Azure resources"

  default = {}
}

variable "network_plugin" {
  description = "Network plugin to use"

  default = "azure"
}

variable "network_policy" {
  description = "Network policy provider to use"

  default = "azure"
}

variable "network_mode" {
  description = "Network mode to use"

  default = "transparent"
}

variable "oidc_issuer_enabled" {
  description = "Enable or Disable the OIDC issuer URL"
  default     = true
}

variable "kubelet_identity_client_id" {
  type        = string
  description = "The Client ID of the user-defined Managed Identity to be assigned to the Kubelets."
  default     = null
}

variable "kubelet_identity_object_id" {
  type        = string
  description = "The Object ID of the user-defined Managed Identity assigned to the Kubelets"
  default     = null
}

variable "kubelet_identity_user_assigned_identity_id" {
  type        = string
  description = "The ID of the User Assigned Identity assigned to the Kubelets"
  default     = null
}
