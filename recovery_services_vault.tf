################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : Recovery Servicesコンテナー、ポリシーの作成とストレージアカウントのバックアップ
## @since   : 2020/06/09
## @see     :
################################################################################
resource "azurerm_recovery_services_vault" "main" {
  for_each            = var.recovery_services_vault
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  location            = azurerm_resource_group.main[each.value.resource_group_key].location
  sku                 = each.value.sku
  soft_delete_enabled = each.value.soft_delete_enabled
}

resource "azurerm_backup_container_storage_account" "main" {
  for_each            = var.backup_storage_account
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  recovery_vault_name = azurerm_recovery_services_vault.main[each.value.recovery_vault_key].name
  storage_account_id  = azurerm_storage_account.main[each.key].id
}

resource "azurerm_backup_policy_vm" "daily" {
  for_each            = var.backup_policy_vm_daily
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  recovery_vault_name = azurerm_recovery_services_vault.main[each.value.recovery_vault_key].name
  timezone            = each.value.timezone

  backup {
    frequency = "Daily"
    time      = each.value.time
  }

  retention_daily {
    count = each.value.count
  }
}

resource "azurerm_backup_policy_vm" "weekly" {
  for_each            = var.backup_policy_vm_weekly
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  recovery_vault_name = azurerm_recovery_services_vault.main[each.value.recovery_vault_key].name
  timezone            = each.value.timezone

  backup {
    frequency = "Weekly"
    time      = each.value.time
    weekdays  = each.value.weekdays
  }

  retention_weekly {
    count    = each.value.count
    weekdays = each.value.weekdays
  }
}

output "recovery_services_vault" {
  value = azurerm_recovery_services_vault.main
}

output "backup_policy_vm_daily" {
  value = azurerm_backup_policy_vm.daily
}

output "backup_policy_vm_weekly" {
  value = azurerm_backup_policy_vm.weekly
}
