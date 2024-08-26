////////////////////////
// External Resources (Required)
////////////////////////

variable "target_resource_group" {
  type = object({
    name     = string
    location = string
  })
}

variable "target_subnet" {
  type = object({
    name                 = string
    virtual_network_name = string
    resource_group_name  = string
  })
}

////////////////////////
// Virtual Machine
////////////////////////

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vm_name" {
  type    = string
  default = "sqlvm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_timezone" {
  type    = string
  default = "W. Europe Standard Time"
}

variable "vm_admin_username" {
  type    = string
  default = "batman"
}

variable "vm_admin_password" {
  type    = string
  default = "BruceW@yn3"
}

variable "vm_priority" {
  type    = string
  default = null
}

variable "vm_eviction_policy" {
  type    = string
  default = null
}

variable "vm_max_bid_price" {
  type    = string
  default = null
}

variable "vm_provision_vm_agent" {
  type    = bool
  default = null
}

variable "vm_enable_automatic_updates" {
  type    = bool
  default = null
}

variable "vm_source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = optional(string, "latest")
  })

  default = {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
  }
}

variable "vm_os_disk" {
  type = object({
    caching              = optional(string, "ReadOnly")
    storage_account_type = optional(string, "Standard_LRS")
    disk_size_gb         = number
  })

  default = {
    disk_size_gb = 127
  }
}

variable "vm_datadisk" {
  description = ""

  type = object({
    size_gb              = optional(number)
    storage_account_type = optional(string, "Standard_LRS")
    create_option        = optional(string, "Empty")
    caching              = optional(string, "ReadWrite")
  })

  default = {
    size_gb = 255
  }
}

variable "vm_logdisk" {
  description = ""

  type = object({
    size_gb              = optional(number)
    storage_account_type = optional(string, "Standard_LRS")
    create_option        = optional(string, "Empty")
    caching              = optional(string, "ReadWrite")
  })

  default = {
    size_gb = 255
  }
}

////////////////////////
// SQL Server
////////////////////////

variable "sql_update_username" {
  type    = string
  default = "BruceWayne"
}

variable "sql_update_password" {
  type    = string
  default = "!!IAmB@tman!!"
}

variable "sql_license_type" {
  description = "N/A"

  type    = string
  default = "PAYG"
}

variable "sql_r_services_enabled" {
  description = "N/A"

  type    = bool
  default = null
}

variable "sql_connectivity_port" {
  description = "N/A"

  type    = number
  default = 1433
}

variable "sql_connectivity_type" {
  description = "N/A"

  type    = string
  default = "PRIVATE"
}

variable "sql_auto_backup" {
  description = "Configure SQL backups. See https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/automated-backup?view=azuresql"

  type = object({
    encryption_enabled              = optional(bool)
    encryption_password             = optional(string)
    system_databases_backup_enabled = optional(bool)
    retention_period_in_days        = number
    storage_blob_endpoint           = string
    storage_account_access_key      = string

    manual_schedule = optional(object({
      full_backup_frequency           = string
      full_backup_start_hour          = number
      full_backup_window_in_hours     = number
      log_backup_frequency_in_minutes = number
      days_of_week                    = optional(list(string)) # For "Weekly" Frequenzy
    }), null)
  })

  default = null
}

variable "sql_auto_patching" {
  description = "N/A"

  type = object({
    day_of_week                            = string
    maintenance_window_starting_hour       = number
    maintenance_window_duration_in_minutes = number
  })

  default = null
}

variable "sql_instance" {
  description = "N/A"

  type = object({
    adhoc_workloads_optimization_enabled = optional(bool)
    collation                            = optional(string)
    instant_file_initialization_enabled  = optional(bool)
    lock_pages_in_memory_enabled         = optional(bool)
    max_dop                              = optional(number)
    max_server_memory_mb                 = optional(number)
    min_server_memory_mb                 = optional(number)
  })

  default = null
}

variable "sql_key_vault_credential" {
  description = "N/A"

  type = object({
    name                     = string
    key_vault_url            = string
    service_principal_name   = string
    service_principal_secret = string
  })

  default = null
}

variable "sql_assessment" {
  description = "N/A"

  type = object({
    enabled         = optional(bool)
    run_immediately = optional(bool)

    schedule = optional(object({
      weekly_interval    = optional(number)
      monthly_occurrence = optional(number)
      day_of_week        = string
      start_time         = string
    }), null)
  })

  default = null
}

variable "sql_storage_configuration" {
  type = object({
    disk_type                      = optional(string, "NEW")
    storage_workload_type          = optional(string, "OLTP")
    system_db_on_data_disk_enabled = optional(bool, false)
  })

  default = {}
}

////////////////////////
// Virtual Machine Extension
////////////////////////

variable "vm_extensions" {
  description = <<-HEREDOC
    Example:
    az vm extension image list -o table --name AADLoginForWindows --publisher Microsoft.Azure.ActiveDirectory --location norwayeast
    az vm extension image list -o table --name BGInfo --publisher Microsoft.Compute --location norwayeast
    az vm extension image list -o table --name AdminCenter --publisher Microsoft.AdminCenter --location norwayeast
    az vm extension image list -o table --name CustomScriptExtension --publisher Microsoft.Compute --location norwayeast
    HEREDOC

  type = list(object({
    name                       = string
    publisher                  = string
    type                       = string
    version                    = string
    auto_upgrade_minor_version = optional(bool)
    automatic_upgrade_enabled  = optional(bool)
    settings                   = optional(string)
    protected_settings         = optional(string)
    enabled                    = optional(bool, true)
  }))

  default = [{
    name      = "AADLogin"
    publisher = "Microsoft.Azure.ActiveDirectory"
    type      = "AADLoginForWindows"
    version   = "2.2"
    }, {
    name      = "BGInfo"
    publisher = "Microsoft.Compute"
    type      = "BGInfo"
    version   = "2.2"
    }, {
    name      = "AdminCenter"
    publisher = "Microsoft.AdminCenter"
    type      = "AdminCenter"
    version   = "0.32"
  }]
}

////////////////////////
// SQL Databases
////////////////////////

/*variable "mssql_databases" {
  description = ""

  type = list(object({
    name                                  = string
    max_size_gb                           = number
    create_mode                           = optional(string)
    sku_name                              = optional(string)
    collation                             = optional(string)
    maintenance_configuration_name        = optional(string)
    ledger_enabled                        = optional(bool)
    license_type                          = optional(string)
    creation_source_database_id           = optional(string)
    restore_point_in_time                 = optional(string)
    recover_database_id                   = optional(string)
    recovery_point_id                     = optional(string)
    restore_dropped_database_id           = optional(string)
    restore_long_term_retention_backup_id = optional(string)
    sample_name                           = optional(string)
    zone_redundant                        = optional(bool)
    read_scale                            = optional(bool)

    import_bacpac = optional(object({
      storage_uri                  = string
      storage_key                  = string
      storage_key_type             = string
      administrator_login          = string
      administrator_login_password = string
      authentication_type          = string
      storage_account_id           = optional(string)
    }))

    threat_detection_policy = optional(object({
      state                      = optional(string)
      disabled_alerts            = optional(string)
      email_account_admins       = optional(string)
      email_adresses             = optional(list(string))
      retention_days             = optional(number)
      storage_account_access_key = optional(string)
      storage_endpoint           = optional(string)
    }))

    long_term_retention_policy = optional(object({
      weekly_retention          = optional(string)
      monthly_retention         = optional(string)
      yearly_retention          = optional(string)
      week_of_year              = optional(number)
      immutable_backups_enabled = optional(bool)
    }))

    short_term_retention_policy = optional(object({
      retention_days           = number
      backup_interval_in_hours = optional(number)
    }))
  }))

  default = []
}*/

////////////////////////
// Network Security Rules
////////////////////////

variable "nsg_rules" {
  type = list(object({
    name                                       = string
    priority                                   = number
    protocol                                   = string
    access                                     = string
    direction                                  = string
    description                                = optional(string)
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))

  default = [{
    direction              = "Inbound"
    priority               = 500
    name                   = "AllowAdminCenter"
    protocol               = "Tcp"
    access                 = "Allow"
    destination_port_range = "6516"
    source_address_prefix  = "*"
    source_port_range      = "*"
    }, {
    direction                  = "Outbound"
    priority                   = 500
    name                       = "AllowAADService"
    protocol                   = "Tcp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "AzureActiveDirectory"
    }, {
    direction                  = "Outbound"
    priority                   = 499
    name                       = "AllowWACService"
    protocol                   = "Tcp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "WindowsAdminCenter"
  }]
}
