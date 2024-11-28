#
# Create a Public IP for the Virtual Machine
#
resource "azurerm_public_ip" "jumphost" {
  name                = "${var.prefix}_jumphost_pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

#
# Create network interfaces on management and external subnets
#
resource "azurerm_network_interface" "jumphost_eth0" {
  name                           = "${var.prefix}_jumphost_mgmt"
  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  ip_forwarding_enabled          = false
  accelerated_networking_enabled = false
  tags                           = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main["management"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_cidrs["main_vnet"]["management"], 50)

    primary              = true
    public_ip_address_id = azurerm_public_ip.jumphost.id
  }
}

resource "azurerm_network_interface" "jumphost_eth1" {
  name                           = "${var.prefix}_jumphost_external"
  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  ip_forwarding_enabled          = false
  accelerated_networking_enabled = false
  tags                           = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main["external"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_cidrs["main_vnet"]["external"], 50)
    primary                       = true
  }
}

#
# Deploy VM
#
locals {
  custom_data_jumphost = <<-EOF
    #!/bin/bash
    mkdir -p /var/log/cloud
    sudo apt install net-tools
    sudo ip route add 10.10.10.0/24 via 10.1.10.1
    sudo echo 'This is a jumphost' > /var/log/cloud/bootstrap.log
    sudo echo 'curl http://10.10.10.10' > ~/test-app.sh
    sudo chmod +x ~/test-app.sh
    EOF
}

resource "azurerm_linux_virtual_machine" "jumphost" {
  name                  = "${var.prefix}_jumphost_vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  tags                  = var.tags
  size                  = "Standard_D2s_v4"
  computer_name         = "jumphost"
  network_interface_ids = [azurerm_network_interface.jumphost_eth0.id, azurerm_network_interface.jumphost_eth1.id]

  admin_username                  = var.admin_username
  admin_password                  = local.admin_password
  disable_password_authentication = false

  custom_data = base64encode(local.custom_data_jumphost)

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.my_keypair.public_key_openssh
  }

  os_disk {
    name                 = "${var.prefix}_jumphost_osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "jumphost_management_pip" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.jumphost.ip_address} pass: ${local.admin_password}"
}
