######################
### Azure Resource ###
######################

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

variable "tags" {
  type        = map(string)
  description = "Azure tags to assign to the Azure resources"
  default     = {}
}

##########################
### Cluster Versioning ###
##########################

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

##################
### API Server ###
##################

variable "api_server_authorized_ip_ranges" {
  description = "List of IP ranges authorized to reach the API server"
  type        = list(string)
  default     = []
}

variable "private_cluster_enabled" {
  description = "Deploy a private cluster control plane. Requires private link + private DNS support. The api_server_authorized_ip_ranges option is disabled when private cluster is enabled."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone id for use by private clusters. If unset, and a private cluster is requested, the DNS zone will be created and managed by AKS"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "SKU Tier of the cluster (\"Paid\" is preferred). The SKU determines the cluster's uptime SLA. Refer to https://learn.microsoft.com/en-us/azure/aks/uptime-sla for more information."
  type        = string
  default     = "Free"
}

#######################
### Identity / RBAC ###
#######################

variable "user_assigned_identity_ids" {
  description = "User Assigned Identity IDs for use by the cluster control plane"
  type        = list(string)
}

variable "kubelet_identity" {
  description = "The user-defined Managed Identity assigned to the Kubelets"
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
  default = null
}

variable "admin_group_object_ids" {
  description = "A list of Azure AAD group object IDs that will receive administrative access to the cluster"
  type        = list(string)
  default     = []
}

variable "local_account_disabled" {
  description = "If true local accounts will be disabled. See the documentation https://learn.microsoft.com/en-us/azure/aks/managed-aad#disable-local-accounts for more information."
  type        = bool
  default     = true
}

#######################
### Network Profile ###
#######################

# IP Ranges
variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  default     = "10.0.0.10"
}

# CNI
variable "network_plugin" {
  description = "Network plugin to use"
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy provider to use"
  default     = "azure"
}

variable "network_mode" {
  description = "Network mode to use"
  default     = "transparent"
}

##########################
### Disk Configuration ###
##########################

variable "disk_encryption_set_id" {
  description = "Used to encrypt the cluster's Nodes and Volumes with Customer Managed Keys. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

#########################
### Default Node Pool ###
#########################

variable "default_node_pool" {
  description = "The configuration details of the cluster's default node pool."
  type = object({
    name                 = optional(string, "system")
    vnet_subnet_id       = string
    vm_size              = optional(string, "Standard_D2s_v3")
    kubernetes_version   = optional(string, null)
    availability_zones   = optional(list(string), null)
    node_labels          = optional(map(string), {})
    node_taints          = optional(list(string), [])
    only_critical_addons = optional(bool, true) # Only run critical workloads (AKS managed) on the node pool when enabled

    node_count             = optional(number, 3) # Only used if enable_auto_scaling is set to false
    enable_auto_scaling    = optional(bool, false)
    auto_scaling_min_nodes = optional(number, 3) # Only used if enable_auto_scaling = true
    auto_scaling_max_nodes = optional(number, 5) # Only used if enable_auto_scaling = true
    max_pods               = optional(number, 60)
    upgrade_max_surge      = optional(string, "33%")

    enable_host_encryption = optional(bool, false)
    os_disk_size_gb        = optional(number, 256)
    os_disk_type           = optional(string, "managed")
  })
}

##############
### Addons ###
##############

variable "oidc_issuer" {
  description = "Enable or Disable the OIDC issuer URL and specifies whether Azure AD Workload Identity should be enabled for the Cluster"
  type = object({
    enabled                   = bool
    workload_identity_enabled = optional(bool, false)
  })
  default = {
    enabled                   = true
    workload_identity_enabled = false
  }

  validation {
    condition = (
      !(var.oidc_issuer.workload_identity_enabled && var.oidc_issuer.enabled == false)
    )

    error_message = "To enable Azure AD Workload Identity oidc_issuer_enabled must be set to true."
  }
}

######################################
### OS Profile / Login Credentials ###
######################################

variable "linux_profile_ssh_key" {
  description = "SSH key for connecting to nodes.  Changing this will update the key on all node pools."
  type        = string
}
