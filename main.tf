////////////////////////
// External Resources
////////////////////////

data "azurerm_resource_group" "x" {
  name = var.target_resource_group.name
}

data "azurerm_subnet" "x" {
  name                 = var.target_subnet.name
  virtual_network_name = var.target_subnet.virtual_network_name
  resource_group_name  = var.target_subnet.resource_group_name
}

data "azurerm_virtual_network" "x" {
  name                = data.azurerm_subnet.x.virtual_network_name
  resource_group_name = data.azurerm_subnet.x.resource_group_name
}

////////////////////////
// Module - Virtual Machine
////////////////////////

module "sql-vm" {
  source = "./modules/windows-vm"
  count  = 1

  resource_group = data.azurerm_resource_group.x
  subnet         = data.azurerm_subnet.x
  tags           = var.tags

  params = {
    vm_name                     = var.vm_name
    vm_size                     = var.vm_size
    vm_timezone                 = var.vm_timezone
    vm_admin_username           = var.vm_admin_username
    vm_admin_password           = var.vm_admin_password
    vm_priority                 = var.vm_priority
    vm_eviction_policy          = var.vm_eviction_policy
    vm_max_bid_price            = var.vm_max_bid_price
    vm_datadisk                 = var.vm_datadisk
    vm_logdisk                  = var.vm_logdisk
    vm_os_disk                  = var.vm_os_disk
    vm_source_image_reference   = var.vm_source_image_reference
    vm_provision_vm_agent       = var.vm_provision_vm_agent
    vm_enable_automatic_updates = var.vm_enable_automatic_updates
  }
}

////////////////////////
// Module - Virtual Machine Extensions
////////////////////////

module "vm-extensions" {
  source = "./modules/vm-extensions"
  count  = length(var.vm_extensions) > 0 ? 1 : 0

  virtual_machine_id = one(module.sql-vm.*.vm_id)
  tags               = var.tags

  params = {
    extensions = var.vm_extensions
  }

  #depends_on = [module.sql-vm]
}

////////////////////////
// Module - SQL Server Instances
////////////////////////

module "sql-server" {
  source = "./modules/sql-server"
  count  = 1

  virtual_machine_id = one(module.sql-vm.*.vm_id)
  tags               = var.tags

  params = {
    sql_update_username       = var.sql_update_username
    sql_update_password       = var.sql_update_password
    sql_license_type          = var.sql_license_type
    sql_r_services_enabled    = var.sql_r_services_enabled
    sql_connectivity_port     = var.sql_connectivity_port
    sql_connectivity_type     = var.sql_connectivity_type
    sql_auto_backup           = var.sql_auto_backup
    sql_auto_patching         = var.sql_auto_patching
    sql_instance              = var.sql_instance
    sql_key_vault_credential  = var.sql_key_vault_credential
    sql_assessment            = var.sql_assessment
    sql_storage_configuration = var.sql_storage_configuration
  }

  /*depends_on = [
    module.sql-vm,
    vm-extensions,
  ]*/
}

////////////////////////
// Module - Netowrk Security Group
////////////////////////

module "nsg" {
  source = "./modules/nsg"
  count  = length(var.nsg_rules) > 0 ? 1 : 0

  resource_group = data.azurerm_resource_group.x
  subnet         = data.azurerm_subnet.x
  asg_id         = one(module.sql-vm.*.asg_id)
  tags           = var.tags

  params = {
    vm_name = var.vm_name
    rules   = var.nsg_rules
  }
}

////////////////////////
// Module - SQL Databases
////////////////////////

/*module "sql-databases" {
  source = "./modules/sql-databases"
  count  = 1

  sql_server_id = one(module.sql-server.*.server_id)
  tags          = var.tags

  params = {
    databases = var.mssql_databases
  }

  depends_on = [
      module.sql-server,
  ]
}*/
