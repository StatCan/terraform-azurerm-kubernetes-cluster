######################
### Azure Resource ###
######################

variable "azure_resource_attributes" {
  description = "Attributes used to describe Azure resources"
  type = object({
    project     = string
    environment = string
    location    = optional(string, "Canada Central")
    instance    = number
  })
  nullable = false
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

variable "tags" {
  type        = map(string)
  description = "Azure tags to assign to the Azure resources"
  default     = {}
}

########################################
### Cluster Versioning & Maintenance ###
########################################

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

variable "node_os_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "The maintenance window for the cluster. Refer to https://learn.microsoft.com/en-us/azure/aks/planned-maintenance for more information."
  type = object({
    allowed = optional(list(object({
      day   = string      # Sunday, Monday, Tuesday, Wednesday, Thursday, Friday or Saturday
      hours = set(number) # An array of hour slots in a day
    }))),
    not_allowed = optional(list(object({
      end   = string
      start = string
    }))),
  })
  default = null
}

variable "maintenance_window_node_os" {
  description = "The maintenance window for the node OS upgrades. Refer to https://learn.microsoft.com/en-us/azure/aks/planned-maintenance for more information."
  type = object({
    frequency    = string # Daily, Weekly, AbsoluteMonthly or RelativeMonthly
    interval     = number
    day_of_week  = optional(string) # Friday, Monday, Saturday, Sunday, Thursday, Tuesday or Wednesday
    day_of_month = optional(number) # Value between 0 and 31 (inclusive)
    week_index   = optional(string) # First, Second, Third, Fourth, or Last

    start_time = optional(string) #  Format is HH:mm
    utc_offset = optional(string)
    duration   = string # The duration of the window for maintenance to run in hours

    not_allowed = optional(list(object({
      end   = string
      start = string
    })), [])
  })
  default = null
}

##################
### API Server ###
##################

variable "api_server" {
  description = "Configuration for the cluster's API server."
  type = object({
    authorized_ip_ranges     = optional(list(string))
    subnet_id                = optional(string)
    vnet_integration_enabled = optional(bool)
  })
  default = null
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

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster. Possible values must begin and end with a letter or number, contain only letters, numbers, and hyphens and be between 1 and 54 characters in length. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "dns_prefix_private_cluster" {
  description = " Specifies the DNS prefix to use with private clusters. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "SKU Tier of the cluster (\"Standard\" is preferred). The SKU determines the cluster's uptime SLA. Refer to https://learn.microsoft.com/en-us/azure/aks/uptime-sla for more information."
  type        = string
  default     = "Standard"
}

variable "support_plan" {
  description = "Specifies the support plan which should be used for this Kubernetes Cluster. Possible values are KubernetesOfficial and AKSLongTermSupport. Defaults to KubernetesOfficial"
  type        = string
  default     = "KubernetesOfficial"
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
  default = {
    client_id                 = null
    object_id                 = null
    user_assigned_identity_id = null
  }
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

# Outbound Type
variable "outbound_type" {
  description = " The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer, userDefinedRouting, managedNATGateway and userAssignedNATGateway."
  default     = "userDefinedRouting"
}

# Load Balancer
variable "load_balancer" {
  description = "The load balancer configuration arguments. The profile can't be enabled if var.outbound_type userDefinedRouting. Refer to https://learn.microsoft.com/en-us/azure/aks/egress-outboundtype for more details."
  type = object({
    sku                                 = optional(string, "standard")
    profile_enabled                     = optional(bool, true)
    profile_idle_timeout_in_minutes     = optional(number, 30)
    profile_managed_outbound_ip_count   = optional(number)
    profile_managed_outbound_ipv6_count = optional(number)
    profile_outbound_ip_address_ids     = optional(set(string))
    profile_outbound_ip_prefix_ids      = optional(set(string))
    profile_outbound_ports_allocated    = optional(number, 0)

  })
  default = {
    profile_enabled = false
  }

  validation {
    condition = (
      !(var.load_balancer.profile_enabled == true && var.load_balancer.sku != "standard")
    )
    error_message = "Enabling var.load_balancer.profile_enabled requires that `load_balancer_sku` be set to `standard`."
  }
}

##########################
### Disk Configuration ###
##########################

variable "disk_encryption_set_id" {
  description = "Used to encrypt the cluster's Nodes and Volumes with Customer Managed Keys. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

#################
### Node Pool ###
#################

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

    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
      }), {
      max_surge                     = "33%"
      drain_timeout_in_minutes      = 30
      node_soak_duration_in_minutes = 0
    })

    enable_host_encryption = optional(bool, false)
    os_disk_size_gb        = optional(number, 256)
    os_disk_type           = optional(string, "managed")
  })
}

variable "auto_scaler_profile" {
  description = "The configuration details for the cluster's auto scaler profile."
  type = object({
    expander      = optional(string, "random")
    scan_interval = optional(string, "10s")

    new_pod_scale_up_delay = optional(string, "0s")

    scale_down_utilization_threshold = optional(number, 0.5)
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string) // defaults to scan_interval
    scale_down_delay_after_failure   = optional(string, "3m")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")

    max_graceful_termination_sec = optional(number, 600)
    max_node_provisioning_time   = optional(string, "15m")
    max_unready_nodes            = optional(number, 3)
    max_unready_percentage       = optional(number, 45)

    skip_nodes_with_local_storage = optional(bool, false)
    skip_nodes_with_system_pods   = optional(bool, true)
    balance_similar_node_groups   = optional(bool, false)
    empty_bulk_delete_max         = optional(number, 10)
  })
  default = null
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

variable "linux_profile_public_ssh_key" {
  description = "The SSH public key used to connect to the cluster's Linux nodes. Changing this will update the key on all node pools. If the value is null, this module will autogenerate an SSH key to use."
  type        = string
  default     = null
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    disk_driver_version         = string
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })

  description = "The Storage Profile object to be used for the AKS Cluster"

  default = {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    disk_driver_version         = "v1"
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
}

###################################
### Monitor Diagnostic Settings ###
###################################

variable "diag_setting" {
  type = map(object({
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    enabled_log_categories         = optional(list(string), ["kube-apiserver", "kube-controller-manager", "cluster-autoscaler"])
    enable_all_metrics             = optional(bool, false)
  }))
  default = null
}
