////////////////////////
// Virtual Machine
////////////////////////

output "virtual_machine_id" {
  sensitive = false
  value     = one(module.sql-vm.*.vm_id)
}

output "network_interface_id" {
  sensitive = false
  value     = one(module.sql-vm.*.nic_id)
}

output "application_security_group_id" {
  sensitive = false
  value     = one(module.sql-vm.*.asg_id)
}

////////////////////////
// SQL Server
////////////////////////

output "sql_server_id" {
  sensitive = false
  value     = one(module.sql-server.*.server_id)
}

////////////////////////
// Misc
////////////////////////

