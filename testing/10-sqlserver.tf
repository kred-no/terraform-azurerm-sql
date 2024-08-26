////////////////////////
// Module
////////////////////////

module "sqlvm" {
  source = "../../terraform-azurerm-sql-server"

  target_resource_group = azurerm_resource_group.main
  target_subnet         = azurerm_subnet.main

  sql_assessment = {
    schedule = {
      weekly_interval = 2
      day_of_week     = "Sunday"
      start_time      = "02:00"
    }
  }

  sql_auto_backup = {
    retention_period_in_days   = 5
    storage_blob_endpoint      = one(azurerm_storage_account.backups.*.primary_blob_endpoint)
    storage_account_access_key = one(azurerm_storage_account.backups.*.primary_access_key)
  }

  sql_auto_patching = {
    day_of_week                            = "Saturday"
    maintenance_window_starting_hour       = 1
    maintenance_window_duration_in_minutes = 180
  }

  #nsg_rules = local.nsg_rules
}
