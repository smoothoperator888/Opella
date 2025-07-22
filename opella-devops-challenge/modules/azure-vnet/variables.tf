variable "name" {
  description = "Name of the virtual network"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must contain only alphanumeric characters and hyphens"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefixes                          = list(string)
    service_endpoints                         = optional(list(string), [])
    delegation                                = optional(string, null)
    private_endpoint_network_policies_enabled = optional(bool, false)
  }))
  default = {
    default = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection plan"
  type        = bool
  default     = false
}

variable "enable_vm_protection" {
  description = "Enable VM protection for the virtual network"
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "Custom DNS servers for the virtual network"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_network_security_groups" {
  description = "Create network security groups for each subnet"
  type        = bool
  default     = true
}

variable "network_security_rules" {
  description = "Security rules for network security groups"
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
  default = {}
}