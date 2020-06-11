################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : リソースグループの作成
## @since   : 2020/06/09
## @see     :
################################################################################
resource "azurerm_resource_group" "main" {
  for_each = var.resource_group
  name     = each.value.name
  location = each.value.location
}

output "resource_group" {
  value = azurerm_resource_group.main
}
