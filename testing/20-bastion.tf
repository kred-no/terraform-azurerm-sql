////////////////////////
// Bastion Host
////////////////////////

resource "azurerm_subnet" "bastion" {
  count = local.bastion_enabled ? 1 : 0

  name = "AzureBastionSubnet"

  address_prefixes = [
    cidrsubnet(element(local.vnet_address_prefixes, 0), 3, 1),
  ]

  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}

resource "azurerm_public_ip" "bastion" {
  count = local.bastion_enabled ? 1 : 0

  name              = "sql-bastion-pip"
  allocation_method = "Static"
  sku               = "Standard"

  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_bastion_host" "main" {
  count = local.bastion_enabled ? 1 : 0

  name                = "sql-bastion-host"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "internal"
    subnet_id            = one(azurerm_subnet.bastion.*.id)
    public_ip_address_id = one(azurerm_public_ip.bastion.*.id)
  }
}

output "bastion" {
  sensitive = false
  value     = one(azurerm_bastion_host.main.*.dns_name)
}