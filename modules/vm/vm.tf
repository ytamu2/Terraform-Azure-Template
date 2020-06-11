################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : 仮想マシンの作成とAzure Backupの設定
## @since   : 2020/06/09
## @see     :
################################################################################

##### Linux OS #####
resource "azurerm_virtual_machine" "vm-linux" {
  count                            = ! var.vm.image.is_windows_image ? 1 : 0
  name                             = var.vm.name
  resource_group_name              = var.vm.resource_group_name
  location                         = var.vm.location
  vm_size                          = var.vm.vm_size
  availability_set_id              = var.vm.availability_set_id
  proximity_placement_group_id     = var.vm.proximity_placement_group_id
  network_interface_ids            = [azurerm_network_interface.vm.id]
  delete_os_disk_on_termination    = var.vm.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.vm.delete_data_disks_on_termination

  storage_image_reference {
    id        = var.vm.image.os_id
    publisher = var.vm.image.os_id == "" ? var.vm.image.publisher : ""
    offer     = var.vm.image.os_id == "" ? var.vm.image.offer : ""
    sku       = var.vm.image.os_id == "" ? var.vm.image.sku : ""
    version   = var.vm.image.os_id == "" ? var.vm.image.version : ""
  }

  storage_os_disk {
    name                      = "${var.vm.name}-osdisk01"
    create_option             = "FromImage"
    caching                   = "ReadWrite"
    managed_disk_type         = var.vm.os_disk.managed_disk_type
    write_accelerator_enabled = var.vm.os_disk.write_accelerator_enabled
  }

  additional_capabilities {
    ultra_ssd_enabled = var.vm.ultra_ssd_enabled
  }

  dynamic storage_data_disk {
    for_each = var.data_disk
    content {
      name                      = "${var.vm.name}-datadisk${format("%02d", storage_data_disk.value.lun + 1)}"
      create_option             = "Empty"
      lun                       = storage_data_disk.value.lun
      disk_size_gb              = storage_data_disk.value.disk_size_gb
      managed_disk_type         = storage_data_disk.value.managed_disk_type
      caching                   = storage_data_disk.value.caching
      write_accelerator_enabled = storage_data_disk.value.write_accelerator_enabled
    }
  }

  os_profile {
    computer_name  = var.vm.name
    admin_username = var.vm.os_profile.admin_username
    admin_password = var.vm.os_profile.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = var.vm.linux.enable_ssh_key

    dynamic ssh_keys {
      for_each = var.vm.linux.enable_ssh_key ? [var.vm.linux.ssh_key] : []
      content {
        path     = "/home/${var.vm.admin_username}/.ssh/authorized_keys"
        key_data = file(var.vm.linux.ssh_key)
      }
    }
  }

  boot_diagnostics {
    enabled     = var.vm.boot_diagnostics.ehable_boot_diagnostics
    storage_uri = var.vm.boot_diagnostics.ehable_boot_diagnostics ? var.vm.boot_diagnostics.primary_blob_endpoint : ""

  }

  tags = var.vm.tags
}

##### Windows OS #####
resource "azurerm_virtual_machine" "vm-windows" {
  count                         = var.vm.image.is_windows_image ? 1 : 0
  name                          = var.vm.name
  resource_group_name           = var.vm.resource_group_name
  location                      = var.vm.location
  availability_set_id           = var.vm.availability_set_id
  vm_size                       = var.vm.vm_size
  network_interface_ids         = [azurerm_network_interface.vm.id]
  delete_os_disk_on_termination = var.vm.delete_os_disk_on_termination
  proximity_placement_group_id  = var.vm.proximity_placement_group_id

  storage_image_reference {
    id        = var.vm.image.os_id
    publisher = var.vm.image.os_id == "" ? var.vm.image.publisher : ""
    offer     = var.vm.image.os_id == "" ? var.vm.image.offer : ""
    sku       = var.vm.image.os_id == "" ? var.vm.image.sku : ""
    version   = var.vm.image.os_id == "" ? var.vm.image.version : ""
  }

  storage_os_disk {
    name                      = "${var.vm.name}-osdisk01"
    create_option             = "FromImage"
    caching                   = "ReadWrite"
    managed_disk_type         = var.vm.os_disk.managed_disk_type
    write_accelerator_enabled = var.vm.os_disk.write_accelerator_enabled
  }

  additional_capabilities {
    ultra_ssd_enabled = var.vm.ultra_ssd_enabled
  }

  dynamic storage_data_disk {
    for_each = var.data_disk
    content {
      name              = "${var.vm.name}-datadisk${format("%02d", storage_data_disk.value.lun + 1)}"
      create_option     = "Empty"
      lun               = storage_data_disk.value.lun
      disk_size_gb      = storage_data_disk.value.disk_size_gb
      managed_disk_type = storage_data_disk.value.managed_disk_type
      caching           = storage_data_disk.value.caching
    }
  }

  os_profile {
    computer_name  = var.vm.name
    admin_username = var.vm.os_profile.admin_username
    admin_password = var.vm.os_profile.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
    timezone           = var.vm.windows.timezone
  }

  boot_diagnostics {
    enabled     = var.vm.boot_diagnostics.ehable_boot_diagnostics
    storage_uri = var.vm.boot_diagnostics.ehable_boot_diagnostics ? var.vm.boot_diagnostics.primary_blob_endpoint : ""
  }

  tags = var.vm.tags
}

##### Network Interface #####
resource "azurerm_network_interface" "vm" {
  name                          = "${var.vm.name}-nic01"
  resource_group_name           = var.vm.resource_group_name
  location                      = var.vm.location
  enable_accelerated_networking = var.vm.network.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm.name}-ip01"
    subnet_id                     = var.vm.network.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm.network.private_ip_address
    public_ip_address_id          = var.vm.network.public_ip_address_id
  }

}

##### Azure Backup設定 #####
resource "azurerm_backup_protected_vm" "vm" {
  count               = length(var.vm.backup.recovery_vault_name) > 0 ? 1 : 0
  resource_group_name = var.vm.resource_group_name
  recovery_vault_name = var.vm.backup.recovery_vault_name
  source_vm_id        = var.vm.image.is_windows_image ? azurerm_virtual_machine.vm-windows[count.index].id : azurerm_virtual_machine.vm-linux[count.index].id
  backup_policy_id    = var.vm.backup.backup_policy_id
}

##### Load Balancerのバックエンド #####
resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count                   = var.vm.load_balancer.ehabled_load_balancer ? 1 : 0
  network_interface_id    = azurerm_network_interface.vm.id
  ip_configuration_name   = azurerm_network_interface.vm.ip_configuration[0].name
  backend_address_pool_id = var.vm.load_balancer.backend_address_pool_id
}
