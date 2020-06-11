################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary :仮想ネットワーク、サブネット、パブリックIPの作成
## @since   : 2020/06/09
## @see     :
################################################################################
resource "azurerm_virtual_network" "main" {
  for_each            = var.virtual_network
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  address_space       = each.value.address_space
  location            = azurerm_resource_group.main[each.value.resource_group_key].location
}

resource "azurerm_subnet" "main" {
  for_each             = var.subnet
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.main[each.value.resource_group_key].name
  virtual_network_name = azurerm_virtual_network.main[each.value.virtual_network_key].name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

resource "azurerm_public_ip" "main" {
  for_each            = var.public_ip
  name                = each.value.name
  resource_group_name = azurerm_resource_group.main[each.value.resource_group_key].name
  sku                 = each.value.sku
  location            = azurerm_resource_group.main[each.value.resource_group_key].location
  allocation_method   = each.value.allocation_method
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}

output "subnet" {
  value = azurerm_subnet.main
}

output "public_ip" {
  value = azurerm_public_ip.main
}
