# Generate a unique Linux username
#
# https://registry.terraform.io/providers/ContentSquare/random/latest/docs/resources/pet
#
resource "random_pet" "linux_username" {
  length = 2
}

# Generate an SSH key pair for the AKS cluster's Linux Profile
#
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
#
resource "tls_private_key" "ssh" {
  count = var.linux_profile_public_ssh_key == null ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a unique Windows username
#
# https://registry.terraform.io/providers/ContentSquare/random/latest/docs/resources/pet
#
resource "random_pet" "windows_username" {
  length = 2
}

# Generate a unique Windows password
#
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
#
resource "random_password" "windows_password" {
  length      = 24
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

# Manages a Managed Kubernetes Cluster
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
#
resource "azurerm_kubernetes_cluster" "this" {
  name                = module.azure_resource_prefixes.kubernetes_service_prefix
  resource_group_name = var.resource_group_name
  location            = var.azure_resource_attributes.location
  node_resource_group = var.node_resource_group_name == null ? "${module.azure_resource_prefixes.resource_group_prefix}-managed-aks" : var.node_resource_group_name

  # Versioning
  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = var.automatic_channel_upgrade != "none" ? var.automatic_channel_upgrade : null
  node_os_channel_upgrade   = var.node_os_channel_upgrade

  # API Server
  sku_tier                   = var.sku_tier
  private_cluster_enabled    = var.private_cluster_enabled
  private_dns_zone_id        = var.private_cluster_enabled ? (var.private_dns_zone_id != null ? var.private_dns_zone_id : "System") : null
  dns_prefix                 = var.dns_prefix
  dns_prefix_private_cluster = var.dns_prefix_private_cluster

  # Encryption
  disk_encryption_set_id = var.disk_encryption_set_id

  # Components
  azure_policy_enabled             = false
  http_application_routing_enabled = false

  # Identity / RBAC
  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server != null ? ["api_server"] : []

    content {
      authorized_ip_ranges     = var.api_server.authorized_ip_ranges
      subnet_id                = var.api_server.subnet_id
      vnet_integration_enabled = var.api_server.vnet_integration_enabled
    }
  }

  kubelet_identity {
    client_id                 = var.kubelet_identity.client_id
    object_id                 = var.kubelet_identity.object_id
    user_assigned_identity_id = var.kubelet_identity.user_assigned_identity_id
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }
  local_account_disabled = var.local_account_disabled

  # Network configuration
  network_profile {
    network_plugin = var.network_plugin
    network_mode   = var.network_mode
    network_policy = var.network_policy

    # Require the use of UserDefinedRouting
    # if want to force the use of a firewall device
    outbound_type = var.outbound_type

    # Load balancer
    load_balancer_sku = var.load_balancer.sku

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer.profile_enabled && var.load_balancer.sku == "standard" ? ["load_balancer_profile"] : []

      content {
        idle_timeout_in_minutes     = var.load_balancer.profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer.profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer.profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer.profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer.profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer.profile_outbound_ports_allocated
      }
    }

    # IP ranges
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip

    ip_versions = ["IPv4"]
  }

  # OS profiles
  linux_profile {
    admin_username = random_pet.linux_username.id

    ssh_key {
      key_data = trimspace(coalesce(var.linux_profile_public_ssh_key, try(tls_private_key.ssh.0.public_key_openssh, null)))
    }
  }

  windows_profile {
    admin_username = random_pet.windows_username.id
    admin_password = random_password.windows_password.result
  }

  # Configure the default node pool
  default_node_pool {
    name                        = var.default_node_pool.name
    temporary_name_for_rotation = "temporary"
    vnet_subnet_id              = var.default_node_pool.vnet_subnet_id
    orchestrator_version        = var.default_node_pool.kubernetes_version != null ? var.default_node_pool.kubernetes_version : var.kubernetes_version
    zones                       = var.default_node_pool.availability_zones

    node_count          = !var.default_node_pool.enable_auto_scaling ? var.default_node_pool.node_count : null
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.auto_scaling_min_nodes : null
    max_count           = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.auto_scaling_max_nodes : null

    # Node configuration
    vm_size               = var.default_node_pool.vm_size
    node_labels           = var.default_node_pool.node_labels
    type                  = "VirtualMachineScaleSets"
    enable_node_public_ip = false
    max_pods              = var.default_node_pool.max_pods

    # Disk configuration
    enable_host_encryption = var.default_node_pool.enable_host_encryption
    os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
    os_disk_type           = var.default_node_pool.os_disk_type
    kubelet_disk_type      = "OS"

    # Only run critical workloads (AKS managed) when enabled
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons

    # Upgrade configuration
    upgrade_settings {
      drain_timeout_in_minutes      = var.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
      max_surge                     = var.default_node_pool.upgrade_settings.max_surge
    }

    ultra_ssd_enabled = true
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? ["default_auto_scaler_profile"] : []

    content {
      expander      = var.auto_scaler_profile.expander
      scan_interval = var.auto_scaler_profile.scan_interval

      new_pod_scale_up_delay = var.auto_scaler_profile.new_pod_scale_up_delay

      scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
      scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
      scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
      scale_down_unready               = var.auto_scaler_profile.scale_down_unready

      max_graceful_termination_sec = var.auto_scaler_profile.max_graceful_termination_sec
      max_node_provisioning_time   = var.auto_scaler_profile.max_node_provisioning_time
      max_unready_nodes            = var.auto_scaler_profile.max_unready_nodes
      max_unready_percentage       = var.auto_scaler_profile.max_unready_percentage

      skip_nodes_with_local_storage = var.auto_scaler_profile.skip_nodes_with_local_storage
      skip_nodes_with_system_pods   = var.auto_scaler_profile.skip_nodes_with_system_pods
      balance_similar_node_groups   = var.auto_scaler_profile.balance_similar_node_groups
      empty_bulk_delete_max         = var.auto_scaler_profile.empty_bulk_delete_max
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? ["maintenance_window"] : []

    content {
      dynamic "allowed" {
        for_each = var.maintenance_window.allowed

        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.maintenance_window.not_allowed

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? ["maintenance_window_node_os"] : []

    content {
      frequency    = var.maintenance_window_node_os.frequency
      day_of_week  = var.maintenance_window_node_os.day_of_week
      day_of_month = var.maintenance_window_node_os.day_of_month
      week_index   = var.maintenance_window_node_os.week_index
      interval     = var.maintenance_window_node_os.interval

      start_time = var.maintenance_window_node_os.start_time
      utc_offset = var.maintenance_window_node_os.utc_offset
      duration   = var.maintenance_window_node_os.duration

      dynamic "not_allowed" {
        for_each = var.maintenance_window_node_os.not_allowed

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  # Addons
  run_command_enabled           = false
  public_network_access_enabled = false
  oidc_issuer_enabled           = var.oidc_issuer.enabled
  workload_identity_enabled     = var.oidc_issuer.workload_identity_enabled

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diag_setting

  name               = each.key
  target_resource_id = azurerm_kubernetes_cluster.this.id

  # Send to log analytics workspace
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type

  # Send to storage account
  storage_account_id = each.value.storage_account_id

  dynamic "enabled_log" {
    for_each = each.value.enabled_log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.enable_all_metrics ? ["enable_all_metrics"] : []
    content {
      enabled  = each.value.enable_all_metrics
      category = "AllMetrics"
    }
  }
}
