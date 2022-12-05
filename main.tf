# Generate a unique Linux username
#
# https://registry.terraform.io/providers/ContentSquare/random/latest/docs/resources/pet
#
resource "random_pet" "linux_username" {
  length = 2
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
resource "azurerm_kubernetes_cluster" "cluster" {
  name                       = "${var.prefix}-aks"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  dns_prefix                 = var.prefix
  dns_prefix_private_cluster = var.prefix

  node_resource_group = var.node_resource_group_name

  # Cluster versioning
  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = var.automatic_channel_upgrade != "none" ? var.automatic_channel_upgrade : null

  # API Server
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  private_cluster_enabled         = var.private_cluster_enabled
  private_dns_zone_id             = var.private_cluster_enabled ? (var.private_dns_zone_id != null ? var.private_dns_zone_id : "System") : null
  sku_tier                        = var.sku_tier

  # Encryption
  disk_encryption_set_id = var.disk_encryption_set_id

  # Identity / RBAC
  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_id
  }

  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Network configuration
  network_profile {
    network_plugin = var.network_plugin
    network_mode   = var.network_mode
    network_policy = var.network_policy

    # Require the use of UserDefinedRouting
    # to force the use of a firewall device
    outbound_type = "userDefinedRouting"

    # Load balancer
    load_balancer_sku = "standard"

    # IP ranges
    docker_bridge_cidr = var.docker_bridge_cidr
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
  }

  # OS profiles
  linux_profile {
    admin_username = random_pet.linux_username.id

    ssh_key {
      key_data = var.ssh_key
    }
  }

  windows_profile {
    admin_username = random_pet.windows_username.id
    admin_password = random_password.windows_password.result
  }

  # Configure the default node pool
  default_node_pool {
    name                 = var.default_node_pool_name
    node_count           = !var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_count : null
    orchestrator_version = var.default_node_pool_kubernetes_version != null ? var.default_node_pool_kubernetes_version : var.kubernetes_version
    zones                = var.default_node_pool_availability_zones
    enable_auto_scaling  = var.default_node_pool_enable_auto_scaling
    min_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_auto_scaling_min_nodes : null
    max_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_auto_scaling_max_nodes : null

    # Node configuration
    vm_size               = var.default_node_pool_vm_size
    node_labels           = var.default_node_pool_labels
    type                  = "VirtualMachineScaleSets"
    enable_node_public_ip = false
    max_pods              = var.default_node_pool_max_pods

    # Disk configuration
    enable_host_encryption = var.default_node_pool_enable_host_encryption
    os_disk_size_gb        = var.default_node_pool_disk_size_gb
    os_disk_type           = var.default_node_pool_disk_type
    kubelet_disk_type      = "OS"

    # Network configuration
    vnet_subnet_id = var.default_node_pool_subnet_id

    # Only run critical workloads (AKS managed) when enabled
    only_critical_addons_enabled = var.default_node_pool_critical_addons_only

    # Upgrade configuration
    upgrade_settings {
      max_surge = var.default_node_pool_upgrade_max_surge
    }

    ultra_ssd_enabled = true
  }

  # Addons
  azure_policy_enabled             = false
  http_application_routing_enabled = false
  tags                             = var.tags
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  run_command_enabled              = false
  public_network_access_enabled    = false

  # Kubelet Identity
  kubelet_identity {
    client_id                 = var.kubelet_identity_client_id
    object_id                 = var.kubelet_identity_object_id
    user_assigned_identity_id = var.kubelet_identity_user_assigned_identity_id
  }
}
