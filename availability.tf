################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : 可用性セット、近接通信配置グループの作成
## @since   : 2020/06/09
## @see     :
################################################################################

resource "azurerm_availability_set" "main" {
  for_each                     = var.availability_set
  name                         = each.value.name
  resource_group_name          = azurerm_resource_group.main[each.value.resource_group_key].name
  location                     = azurerm_resource_group.main[each.value.resource_group_key].location
  platform_fault_domain_count  = each.value.platform_fault_domain_count
  platform_update_domain_count = each.value.platform_update_domain_count
  proximity_placement_group_id = length(each.value.proximity_placement_group_key) > 0 ? azurerm_proximity_placement_group.main[each.value.proximity_placement_group_key].id : ""
}

resource "azurerm_proximity_placement_group" "main" {
  for_each            = var.proximity_placement_group
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  location            = azurerm_resource_group.main[each.value.resource_group_key].location
}

output "availability_set" {
  value = azurerm_availability_set.main
}

output "proximity_placement_group" {
  value = azurerm_proximity_placement_group.main
}
