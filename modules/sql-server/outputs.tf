output "server_id" {
  sensitive = false
  value = azurerm_mssql_virtual_machine.main.id
}
