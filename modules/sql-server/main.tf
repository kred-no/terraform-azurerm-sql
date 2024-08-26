resource "azurerm_mssql_virtual_machine" "main" {
  sql_license_type                 = var.params.sql_license_type
  r_services_enabled               = var.params.sql_r_services_enabled
  sql_connectivity_port            = var.params.sql_connectivity_port
  sql_connectivity_type            = var.params.sql_connectivity_type
  sql_connectivity_update_username = var.params.sql_update_username
  sql_connectivity_update_password = var.params.sql_update_password

  dynamic "sql_instance" {
    for_each = var.params.sql_instance[*]

    content {
      adhoc_workloads_optimization_enabled = sql_instance.value["adhoc_workloads_optimization_enabled"]
      collation                            = sql_instance.value["collation"]
      instant_file_initialization_enabled  = sql_instance.value["instant_file_initialization_enabled"]
      lock_pages_in_memory_enabled         = sql_instance.value["lock_pages_in_memory_enabled"]
      max_dop                              = sql_instance.value["max_dop"]
      max_server_memory_mb                 = sql_instance.value["max_vm_memory_mb"]
      min_server_memory_mb                 = sql_instance.value["min_vm_memory_mb"]
    }
  }

  storage_configuration {
    disk_type                      = var.params.sql_storage_configuration.disk_type
    storage_workload_type          = var.params.sql_storage_configuration.storage_workload_type
    system_db_on_data_disk_enabled = var.params.sql_storage_configuration.system_db_on_data_disk_enabled

    data_settings {
      default_file_path = "F:\\Data"
      luns              = [1]
    }

    log_settings {
      default_file_path = "G:\\Log"
      luns              = [2]
    }

    temp_db_settings {
      default_file_path = "D:\\TempDb" // Ephemeral disk
      luns              = []
    }
  }

  dynamic "key_vault_credential" {
    for_each = var.params.sql_key_vault_credential[*]

    content {
      name                     = key_vault_credential.value["name"]
      key_vault_url            = key_vault_credential.value["key_vault_url"]
      service_principal_name   = key_vault_credential.value["service_principal_name"]
      service_principal_secret = key_vault_credential.value["service_principal_secret"]
    }
  }

  dynamic "assessment" {
    for_each = var.params.sql_assessment[*]

    content {
      enabled         = assessment.value["enabled"]
      run_immediately = assessment.value["run_immediately"]

      dynamic "schedule" {
        for_each = assessment.value["schedule"][*]

        content {
          weekly_interval    = schedule.value["weekly_interval"]
          monthly_occurrence = schedule.value["monthly_occurrence"]
          day_of_week        = schedule.value["day_of_week"]
          start_time         = schedule.value["start_time"]
        }
      }
    }
  }

  dynamic "auto_patching" {
    for_each = var.params.sql_auto_patching[*]

    content {
      day_of_week                            = auto_patching.value["day_of_week"]
      maintenance_window_starting_hour       = auto_patching.value["maintenance_window_starting_hour"]
      maintenance_window_duration_in_minutes = auto_patching.value["maintenance_window_duration_in_minutes"]
    }
  }

  dynamic "auto_backup" {
    for_each = var.params.sql_auto_backup[*]

    content {
      encryption_enabled              = auto_backup.value["encryption_enabled"]
      encryption_password             = auto_backup.value["encryption_password"]
      retention_period_in_days        = auto_backup.value["retention_period_in_days"]
      storage_blob_endpoint           = auto_backup.value["storage_blob_endpoint"]
      storage_account_access_key      = auto_backup.value["storage_account_access_key"]
      system_databases_backup_enabled = auto_backup.value["system_databases_backup_enabled"]

      dynamic "manual_schedule" {
        for_each = auto_backup.value["manual_schedule"][*]

        content {
          full_backup_frequency           = manual_schedule.value["full_backup_frequency"]
          full_backup_start_hour          = manual_schedule.value["full_backup_start_hour"]
          full_backup_window_in_hours     = manual_schedule.value["full_backup_window_in_hours"]
          log_backup_frequency_in_minutes = manual_schedule.value["log_backup_frequency_in_minutes"]
          days_of_week                    = manual_schedule.value["days_of_week"]
        }
      }
    }
  }

  tags               = var.tags
  virtual_machine_id = var.virtual_machine_id
}
