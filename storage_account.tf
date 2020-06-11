################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : ストレージアカウントの作成
## @since   : 2020/06/09
## @see     :
################################################################################
resource "azurerm_storage_account" "main" {
  for_each                 = var.storage_account
  name                     = lower(each.value.name)
  resource_group_name      = azurerm_resource_group.main[each.value.resource_group_key].name
  location                 = azurerm_resource_group.main[each.value.resource_group_key].location
  account_kind             = each.value.account_kind
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  access_tier              = each.value.access_tier

  network_rules {
    default_action = each.value.default_action
    bypass         = each.value.default_action == "Deny" ? each.value.bypass : []
    ip_rules       = each.value.default_action == "Deny" ? each.value.ip_rules : []
    virtual_network_subnet_ids = [
      for sub in each.value.allow_subnets :
      each.value.default_action == "Deny" ? azurerm_subnet.main[sub].id : ""
    ]
  }
}

output "storage_account" {
  value = azurerm_storage_account.main
}
