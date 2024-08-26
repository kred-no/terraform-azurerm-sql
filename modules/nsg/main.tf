resource "azurerm_network_security_group" "main" {
  name = join("-", [var.params.vm_name, "nsg"])

  dynamic "security_rule" {
    for_each = {
      for rule in var.params.rules : rule.name => rule
    }

    content {
      name     = security_rule.value.name
      priority = security_rule.value.priority

      direction   = security_rule.value.direction
      description = security_rule.value.description
      protocol    = security_rule.value.protocol
      access      = security_rule.value.access

      source_port_range       = security_rule.value.source_port_range
      source_port_ranges      = security_rule.value.source_port_ranges
      source_address_prefix   = security_rule.value.source_address_prefix
      source_address_prefixes = security_rule.value.source_address_prefixes

      source_application_security_group_ids = alltrue([
        security_rule.value.direction == "Outbound",
        security_rule.value.source_application_security_group_ids == null,
        security_rule.value.source_address_prefix == null,
        security_rule.value.source_address_prefixes == null,
      ]) ? [var.asg_id] : []

      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes

      destination_application_security_group_ids = alltrue([
        security_rule.value.direction == "Inbound",
        security_rule.value.destination_application_security_group_ids == null,
        security_rule.value.destination_address_prefix == null,
        security_rule.value.destination_address_prefixes == null,
      ]) ? [var.asg_id] : []

    }
  }

  tags                = var.tags
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = var.subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}