resource "azurerm_route_table" "vip" {
  name                = "${var.prefix}_vip_rt"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  route {
    name                   = "vip_subnet"
    address_prefix         = var.vip_udr["dest"]
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.vip_udr["gateway"]
  }
  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.main["external"].id
  route_table_id = azurerm_route_table.vip.id
}

