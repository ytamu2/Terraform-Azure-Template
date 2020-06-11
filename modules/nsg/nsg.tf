################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : Network Security Groupの作成と関連付け
## @since   : 2020/06/09
## @see     :
################################################################################
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg.name
  resource_group_name = var.nsg.resource_group_name
  location            = var.nsg.location

  tags = var.nsg.tags
}

resource "azurerm_network_security_rule" "nsg" {
  for_each                     = var.security_rule
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_address_prefix        = each.value.source_address_prefix
  source_port_range            = each.value.source_port_range
  destination_address_prefixes = each.value.destination_address_prefixes
  destination_port_ranges      = each.value.destination_port_ranges
  network_security_group_name  = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  for_each                  = var.nsg.subnet_association
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg" {
  for_each                  = var.nsg.nic_association
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
