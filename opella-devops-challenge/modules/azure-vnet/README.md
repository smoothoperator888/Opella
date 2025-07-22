# Azure Virtual Network Terraform Module

This module creates an Azure Virtual Network (VNET) with support for multiple subnets, network security groups, and various security features.

## Features

- Creates Azure Virtual Network with customizable address space
- Supports multiple subnets with different configurations
- Optional Network Security Groups (NSGs) for each subnet
- Support for service endpoints and subnet delegations
- Optional DDoS protection
- Custom DNS server configuration
- Comprehensive tagging support

## Usage

```hcl
module "vnet" {
  source = "./modules/azure-vnet"

  name                = "my-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]

  subnets = {
    web = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    app = {
      address_prefixes = ["10.0.2.0/24"]
    }
    db = {
      address_prefixes                          = ["10.0.3.0/24"]
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
      }
    ]
  }

  tags = {
    Environment = "dev"
    Project     = "myproject"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the virtual network | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| address_space | Address space for the virtual network | `list(string)` | `["10.0.0.0/16"]` | no |
| subnets | Map of subnet configurations | `map(object)` | See variables.tf | no |
| enable_ddos_protection | Enable DDoS protection plan | `bool` | `false` | no |
| enable_vm_protection | Enable VM protection for the virtual network | `bool` | `false` | no |
| dns_servers | Custom DNS servers for the virtual network | `list(string)` | `[]` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| create_network_security_groups | Create network security groups for each subnet | `bool` | `true` | no |
| network_security_rules | Security rules for network security groups | `map(list(object))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | ID of the virtual network |
| vnet_name | Name of the virtual network |
| vnet_address_space | Address space of the virtual network |
| subnet_ids | Map of subnet names to their IDs |
| subnet_address_prefixes | Map of subnet names to their address prefixes |
| network_security_group_ids | Map of network security group names to their IDs |
| network_security_group_names | Map of subnet names to their associated NSG names |
| resource_group_name | Name of the resource group containing the VNET |
| location | Azure region of the VNET |

## Examples

### Basic VNET with single subnet

```hcl
module "basic_vnet" {
  source = "./modules/azure-vnet"

  name                = "basic-vnet"
  resource_group_name = "my-rg"
  location            = "eastus"
}
```

### VNET with multiple subnets and NSGs

```hcl
module "complex_vnet" {
  source = "./modules/azure-vnet"

  name                = "complex-vnet"
  resource_group_name = "my-rg"
  location            = "eastus"
  address_space       = ["172.16.0.0/12"]

  subnets = {
    frontend = {
      address_prefixes = ["172.16.1.0/24"]
    }
    backend = {
      address_prefixes  = ["172.16.2.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    management = {
      address_prefixes = ["172.16.3.0/24"]
    }
  }

  enable_ddos_protection = true
  dns_servers           = ["168.63.129.16"]

  tags = {
    Environment = "production"
    CostCenter  = "IT"
  }
}
```

## Testing

This module includes basic validation tests. To run tests:

```bash
cd tests
terraform init
terraform test
```