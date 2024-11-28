# main.tf

# Local variables
locals {
  resource_group = "${var.prefix}_rg"
}

# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group
  location = var.location
  tags     = var.tags
}

output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}
