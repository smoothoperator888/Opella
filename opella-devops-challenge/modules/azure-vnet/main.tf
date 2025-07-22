terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.0"
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      enable = true
    }
  }

  dns_servers = length(var.dns_servers) > 0 ? var.dns_servers : null

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  service_endpoints = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [1] : []
    content {
      name = "delegation"
      service_delegation {
        name = each.value.delegation
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = var.create_network_security_groups ? var.subnets : {}

  name                = "${var.name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for rule in flatten([
      for subnet_name, rules in var.network_security_rules : [
        for rule in rules : {
          key         = "${subnet_name}-${rule.name}"
          subnet_name = subnet_name
          rule        = rule
        }
      ]
    ]) : rule.key => rule
  }

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_name].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.create_network_security_groups ? var.subnets : {}

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}