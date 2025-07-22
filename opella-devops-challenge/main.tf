terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateopella"
    container_name       = "tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  environment_config = {
    dev = {
      location             = "eastus"
      address_space        = ["10.0.0.0/16"]
      subnet_address_map   = {
        web  = ["10.0.1.0/24"]
        app  = ["10.0.2.0/24"]
        data = ["10.0.3.0/24"]
      }
      vm_size              = "Standard_B2s"
      storage_replication  = "LRS"
    }
    prod = {
      location             = "eastus2"
      address_space        = ["172.16.0.0/16"]
      subnet_address_map   = {
        web  = ["172.16.1.0/24"]
        app  = ["172.16.2.0/24"]
        data = ["172.16.3.0/24"]
      }
      vm_size              = "Standard_D2s_v3"
      storage_replication  = "GRS"
    }
  }

  config = local.environment_config[var.environment]
  
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "opella-devops-challenge"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
    }
  )
}

resource "azurerm_resource_group" "main" {
  name     = "rg-opella-${var.environment}-${local.config.location}"
  location = local.config.location
  
  tags = local.common_tags
}

module "vnet" {
  source = "./modules/azure-vnet"

  name                = "vnet-opella-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = local.config.address_space

  subnets = {
    web = {
      address_prefixes  = local.config.subnet_address_map.web
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    app = {
      address_prefixes  = local.config.subnet_address_map.app
      service_endpoints = ["Microsoft.Storage"]
    }
    data = {
      address_prefixes                          = local.config.subnet_address_map.data
      private_endpoint_network_policies_enabled = true
    }
  }

  create_network_security_groups = true
  
  network_security_rules = {
    web = [
      {
        name                       = "allow-http"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-https"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  tags = local.common_tags
}