////////////////////////
// Extensions
////////////////////////

resource "azurerm_virtual_machine_extension" "main" {
  for_each = {
    for ext in var.params.extensions : ext.name => ext
    if ext.enabled
  }

  name      = each.value.name
  publisher = each.value.publisher
  type      = each.value.type

  type_handler_version       = each.value.version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled  = each.value.automatic_upgrade_enabled

  settings           = each.value.settings
  protected_settings = each.value.protected_settings

  tags               = var.tags
  virtual_machine_id = var.virtual_machine_id

  lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
    ]
  }
}
