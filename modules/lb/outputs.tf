output "load_balancer" {
  value = azurerm_lb.lb
}

output "lb_backend_address_pool" {
  value = azurerm_lb_backend_address_pool.lb
}
