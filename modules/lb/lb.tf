################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : Azure Load Balancerの作成
## @since   : 2020/06/10
## @see     :
################################################################################
resource "azurerm_lb" "lb" {
  name                = var.lb.name
  resource_group_name = var.lb.resource_group_name
  location            = var.lb.location
  sku                 = var.lb.sku

  frontend_ip_configuration {
    name                          = var.lb.frontend_ip_configuration.name
    subnet_id                     = var.lb.is_private ? var.lb.frontend_ip_configuration.subnet_id : ""
    private_ip_address            = var.lb.is_private ? var.lb.frontend_ip_configuration.private_ip_address : ""
    private_ip_address_allocation = var.lb.frontend_ip_configuration.private_ip_address_allocation
    private_ip_address_version    = var.lb.frontend_ip_configuration.private_ip_address_version
    public_ip_address_id          = ! var.lb.is_private ? var.lb.frontend_ip_configuration.public_ip_address_id : ""
  }

  tags = var.lb.tags
}

resource "azurerm_lb_backend_address_pool" "lb" {
  resource_group_name = var.lb.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = var.lb.backend_address_pool_name
}

resource "azurerm_lb_probe" "lb" {
  for_each            = var.lb.probe
  resource_group_name = var.lb.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.value.name
  protocol            = each.value.protocol
  port                = each.value.port
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

resource "azurerm_lb_rule" "lb" {
  for_each                       = var.lb_rule
  resource_group_name            = var.lb.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb.id
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb[each.value.plobe_key].id
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  disable_outbound_snat          = each.value.disable_outbound_snat
  enable_tcp_reset               = each.value.enable_tcp_reset
}
