resource "azurerm_resource_group" "k8s_rg" {
  name     = "${lower(var.project_name)}-${var.k8s_resource_group_name_suffix}"
  location = var.location
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  count       = var.enable_log_analytics ? 1 : 0
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  count               = var.enable_log_analytics ? 1 : 0
  name                = "${lower(var.project_name)}-log-analytics-ws-${random_id.log_analytics_workspace_name_suffix[0].dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "log_analytics_deployment" {
  count                 = var.enable_log_analytics ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log_analytics_ws[0].location
  resource_group_name   = azurerm_resource_group.k8s_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_ws[0].id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_ws[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "${lower(var.project_name)}-${var.k8s_cluster_name_suffix}"
  location            = azurerm_resource_group.k8s_rg.location
  resource_group_name = azurerm_resource_group.k8s_rg.name
  dns_prefix          = var.k8s_dns_prefix
  # Use Managed Identity for K8S cluster identity
  # https://www.chriswoolum.dev/aks-with-managed-identity-and-terraform
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "agentpool"
    node_count = var.k8s_agent_count
    vm_size    = "Standard_D2_v2"
  }
  dynamic "addon_profile" {
    for_each = var.enable_log_analytics ? [1] : []
    content {
      oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_ws[0].id
      }
      kube_dashboard {
        enabled = false
      }
    }
  }
  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }
  tags = {
    environment = var.environment
  }
}