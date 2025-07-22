resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  name                     = "stopella${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = local.config.storage_replication
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.vnet.subnet_ids["app"]]
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "main" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}