### Deploy a Linux server with the F5 Demo and Juice Shop applications running on Docker

#
# Create network interface on application subnet
#
resource "azurerm_network_interface" "app_eth0" {
  name                = "${var.prefix}_app_eth0"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "application"
    subnet_id                     = azurerm_subnet.main["application"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_cidrs["main_vnet"]["application"], 100)
    primary                       = true
  }
}

#
# Deploy VM
#
locals {
  custom_data_appsvr = <<-EOF
    #!/bin/bash
    apt-get update -y;
    apt-get install -y docker.io;
    # demo app
    docker run -d -p 443:443 -p 80:80 --restart unless-stopped -e F5DEMO_APP=website -e F5DEMO_NODENAME='F5 Azure' -e F5DEMO_COLOR=ffd734 -e F5DEMO_NODENAME_SSL='F5 Azure (SSL)' -e F5DEMO_COLOR_SSL=a0bf37 chen23/f5-demo-app:ssl;
    # juice shop
    docker run -d --restart always -p 3000:3000 bkimminich/juice-shop
    # rsyslogd with PimpMyLogs
    docker run -d -e SYSLOG_USERNAME=${var.admin_username} -e SYSLOG_PASSWORD=${local.admin_password} -p 8080:80 -p 514:514/udp pbertera/syslogserver
    EOF

}

resource "azurerm_linux_virtual_machine" "app" {
  name                  = "${var.prefix}_app_vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  tags                  = var.tags
  size                  = "Standard_D2s_v4"
  computer_name         = "appsvr"
  network_interface_ids = [azurerm_network_interface.app_eth0.id]

  admin_username                  = var.admin_username
  admin_password                  = local.admin_password
  disable_password_authentication = false

  custom_data = base64encode(local.custom_data_appsvr)

  os_disk {
    name                 = "${var.prefix}_appsvr_osdisk"
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
