////////////////////////
// SQL-VM | Application Security Group
////////////////////////

resource "azurerm_application_security_group" "main" {
  name                = join("-", [var.params.vm_name, "asg"])
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

////////////////////////
// SQL-VM | Network Interface
////////////////////////

resource "azurerm_network_interface" "main" {
  name = join("-", [var.params.vm_name, "nic"])

  ip_configuration {
    name                          = join("-", [var.params.vm_name, "ipcfg"])
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet.id
  }

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_network_interface_application_security_group_association" "main" {
  network_interface_id          = azurerm_network_interface.main.id
  application_security_group_id = azurerm_application_security_group.main.id
}

////////////////////////
// SQL-VM | Managed Disks
////////////////////////

resource "azurerm_managed_disk" "data" {
  name                 = join("-", [var.params.vm_name, "datadisk"])
  storage_account_type = var.params.vm_datadisk.storage_account_type #"Standard_LRS"
  create_option        = var.params.vm_datadisk.create_option        #"Empty"
  disk_size_gb         = var.params.vm_datadisk.size_gb

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

resource "azurerm_managed_disk" "log" {
  name                 = join("-", [var.params.vm_name, "logdisk"])
  storage_account_type = var.params.vm_logdisk.storage_account_type #"Standard_LRS"
  create_option        = var.params.vm_logdisk.create_option        #"Empty"
  disk_size_gb         = var.params.vm_logdisk.size_gb

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

////////////////////////
// SQL-VM | Windows Virtual Machine
////////////////////////

resource "azurerm_windows_virtual_machine" "main" {
  // Create disks before creating the VM
  depends_on = [
    azurerm_managed_disk.data,
    azurerm_managed_disk.log,
  ]

  name            = var.params.vm_name
  size            = var.params.vm_size
  timezone        = var.params.vm_timezone
  admin_username  = var.params.vm_admin_username
  admin_password  = var.params.vm_admin_password
  priority        = var.params.vm_priority
  eviction_policy = var.params.vm_eviction_policy
  max_bid_price   = var.params.vm_max_bid_price

  provision_vm_agent       = var.params.vm_provision_vm_agent
  enable_automatic_updates = var.params.vm_enable_automatic_updates

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  dynamic "source_image_reference" {
    for_each = var.params.vm_source_image_reference[*]

    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }

  dynamic "os_disk" {
    for_each = var.params.vm_os_disk[*]

    content {
      name                 = join("-", [var.params.vm_name, "osdisk"])
      caching              = os_disk.value["caching"]
      storage_account_type = os_disk.value["storage_account_type"]
      disk_size_gb         = os_disk.value["disk_size_gb"]
    }
  }

  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = var.tags
}

////////////////////////
// SQL-VM | Managed Disks Attachment
////////////////////////

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  lun     = 1
  caching = var.params.vm_datadisk.caching

  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  managed_disk_id    = azurerm_managed_disk.data.id
}

resource "azurerm_virtual_machine_data_disk_attachment" "log" {
  lun     = 2
  caching = var.params.vm_logdisk.caching

  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  managed_disk_id    = azurerm_managed_disk.log.id
}
