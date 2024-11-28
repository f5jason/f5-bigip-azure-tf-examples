# Deploy Internal Azure Load Balancer (ILB)

# Create Azure LB
resource "azurerm_lb" "bigip_ha" {
  name                = "${var.prefix}_lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "${var.prefix}_f5_router"
    subnet_id                     = azurerm_subnet.main["external"].id
    private_ip_address            = var.vip_udr["gateway"]
    private_ip_address_allocation = "Static"
  }
}

# Create backend pool
resource "azurerm_lb_backend_address_pool" "bigip_ha" {
  name            = "${var.prefix}_f5_pool"
  loadbalancer_id = azurerm_lb.bigip_ha.id
}

# Add interfaces to backend pool
resource "azurerm_network_interface_backend_address_pool_association" "bigip1" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.bigip_ha.id
  network_interface_id    = azurerm_network_interface.bigip1["external"].id
  ip_configuration_name   = "secondary"
}

resource "azurerm_network_interface_backend_address_pool_association" "bigip2" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.bigip_ha.id
  network_interface_id    = azurerm_network_interface.bigip2["external"].id
  ip_configuration_name   = "secondary"
}


# Create health probe
resource "azurerm_lb_probe" "tcp3456" {
  loadbalancer_id     = azurerm_lb.bigip_ha.id
  name                = "${var.prefix}_probe_tcp3456"
  port                = 3456
  interval_in_seconds = 5
  number_of_probes    = 3
  protocol            = "Tcp"
}

# Create load balancing rule
resource "azurerm_lb_rule" "bigip_ha" {
  loadbalancer_id                = azurerm_lb.bigip_ha.id
  name                           = "${var.prefix}_rule_bigip_ha"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  probe_id                       = azurerm_lb_probe.tcp3456.id
  frontend_ip_configuration_name = azurerm_lb.bigip_ha.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bigip_ha.id]
  enable_floating_ip             = true
  idle_timeout_in_minutes        = 15
  enable_tcp_reset               = true
}
