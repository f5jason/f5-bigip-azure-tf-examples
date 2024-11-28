# main VNet

# Create vnet and Subnets
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}_${var.vnet_name}"
  address_space       = [var.vnet_cidrs["main_vnet"]["vnet"]]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  for_each             = { for k, v in var.vnet_cidrs["main_vnet"] : k => v if k != "vnet" }
  name                 = each.key
  address_prefixes     = [each.value]
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
}


output "demo_vnet" {
  description = "vnet name"
  value       = azurerm_virtual_network.main.name
}
