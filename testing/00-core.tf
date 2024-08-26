locals {
  # Static configuration
  bastion_enabled       = false
  location              = "norwayeast"
  vnet_address_prefixes = ["10.99.99.0/24"]
  #nsg_rules             = []
}

////////////////////////
// Unique ID generators
////////////////////////

resource "random_string" "rg-main" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true

  keepers = {
    prefix   = "RgSql"
    location = local.location
  }
}

resource "random_string" "sacc-main" {
  length  = 16
  lower   = true
  numeric = true
  upper   = false
  special = false

  keepers = {
    prefix   = "sacc"
    location = local.location
  }
}

/*resource "random_string" "kv-main" {
  length  = 16
  lower   = true
  numeric = true
  upper   = false
  special = false

  keepers = {
    prefix   = "kvlt"
    location = var.location
  }
}*/

////////////////////////
// Resource Group
////////////////////////

resource "azurerm_resource_group" "main" {
  # Max 15 characters, if using AAD-join
  name = join("", [random_string.rg-main.keepers.prefix, random_string.rg-main.result])

  location = local.location
}

////////////////////////
// Network
////////////////////////

resource "azurerm_virtual_network" "main" {
  name                = "SqlModuleVirtualNetwork"
  address_space       = local.vnet_address_prefixes
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet" "main" {
  name = "SqlVmSubnet"

  address_prefixes = [
    cidrsubnet(element(local.vnet_address_prefixes, 0), 3, 0),
  ]

  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
}

////////////////////////
// Backup Storage
////////////////////////

resource "azurerm_storage_account" "backups" {
  count = 1

  name                     = join("", [random_string.sacc-main.keepers.prefix, random_string.sacc-main.result])
  account_tier             = "Standard"
  account_replication_type = "LRS"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}
