# Create Network Security Group and rules
resource "azurerm_network_security_group" "mgmt" {
  name                = "${var.prefix}_mgmt_nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  security_rule {
    name                       = "allow_admin_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = local.remote_client_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_admin_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = local.remote_client_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_admin_HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = local.remote_client_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_admin_HTTPS_3000"
    description                = "Allow HTTPS access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefixes    = local.remote_client_ip
    destination_address_prefix = "*"
  }
}

# Apply NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.main["management"].id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

resource "azurerm_subnet_network_security_group_association" "external" {
  subnet_id                 = azurerm_subnet.main["external"].id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

