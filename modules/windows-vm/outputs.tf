output "asg_id" {
  sensitive = false
  value     = azurerm_application_security_group.main.id
}

output "nic_id" {
  sensitive = false
  value     = azurerm_network_interface.main.id
}

output "datadisk_id" {
  sensitive = false
  value     = azurerm_managed_disk.data.id
}

output "logdisk_id" {
  sensitive = false
  value     = azurerm_managed_disk.log.id
}

output "vm_id" {
  sensitive = false
  value     = azurerm_windows_virtual_machine.main.id
}

