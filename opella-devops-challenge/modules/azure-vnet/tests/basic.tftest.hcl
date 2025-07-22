provider "azurerm" {
  features {}
}

run "valid_vnet_creation" {
  command = plan

  variables {
    name                = "test-vnet"
    resource_group_name = "test-rg"
    location            = "eastus"
    address_space       = ["10.0.0.0/16"]
    
    subnets = {
      test = {
        address_prefixes = ["10.0.1.0/24"]
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network.this.name == "test-vnet"
    error_message = "VNET name should match input"
  }

  assert {
    condition     = azurerm_virtual_network.this.address_space[0] == "10.0.0.0/16"
    error_message = "Address space should match input"
  }

  assert {
    condition     = length(azurerm_subnet.this) == 1
    error_message = "Should create one subnet"
  }
}

run "multiple_subnets" {
  command = plan

  variables {
    name                = "multi-subnet-vnet"
    resource_group_name = "test-rg"
    location            = "eastus"
    
    subnets = {
      web = {
        address_prefixes = ["10.0.1.0/24"]
      }
      app = {
        address_prefixes = ["10.0.2.0/24"]
      }
      db = {
        address_prefixes = ["10.0.3.0/24"]
      }
    }
  }

  assert {
    condition     = length(azurerm_subnet.this) == 3
    error_message = "Should create three subnets"
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 3
    error_message = "Should create NSG for each subnet by default"
  }
}