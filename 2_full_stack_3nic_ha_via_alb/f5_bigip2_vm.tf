# Deploy BIG-IP #2

resource "random_id" "bigip2" {
  byte_length = 8
}

# Create Public IP for management access
resource "azurerm_public_ip" "bigip2-mgmt" {
  name                = "${var.prefix}-bigip2-${random_id.bigip2.hex}-pip-mgmt"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  #sku                 = "Standard"
  allocation_method = "Static"
  domain_name_label = "bigip2-${random_id.bigip2.hex}-management"
  tags              = var.tags
}


# Create NICs for BIG-IP
resource "azurerm_network_interface" "bigip2" {
  for_each              = toset(var.bigip_subnets)
  name                  = "${var.prefix}-bigip2-${random_id.bigip2.hex}-nic-${each.key}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  ip_forwarding_enabled = true
  tags                  = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.main[each.key].id
    private_ip_address_allocation = "Static"
    private_ip_address            = split("/", var.bigip_netcfg["bigip2"][each.key])[0]
    primary                       = true

    # Add Public IP only if 'management' subnet
    public_ip_address_id = each.key == "management" ? azurerm_public_ip.bigip2-mgmt.id : null
  }

  # Add secondary IP only if 'external' subnet. The secondary IP acts as the ILB backend pool member.
  dynamic "ip_configuration" {
    for_each = each.key == "external" ? [1] : []
    content {
      name                          = "secondary"
      subnet_id                     = azurerm_subnet.main[each.key].id
      private_ip_address_allocation = "Static"
      private_ip_address            = split("/", var.bigip_netcfg["bigip2"]["external_secondary"])[0]
    }
  }
}

# Create F5 BIG-IP VM
resource "azurerm_linux_virtual_machine" "bigip2" {
  name                            = "${var.prefix}-bigip2-${random_id.bigip2.hex}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.instance_type
  computer_name                   = "bigip2-${random_id.bigip2.hex}"
  network_interface_ids           = [for subnet in var.bigip_subnets : azurerm_network_interface.bigip2["${subnet}"].id]
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = local.admin_password
  custom_data                     = base64encode(data.template_file.f5-init-startup-bigip2.rendered)
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.my_keypair.public_key_openssh
  }

  os_disk {
    name                 = "${var.prefix}-bigip2-${random_id.bigip2.hex}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }

  plan {
    name      = var.image_name
    publisher = "f5-networks"
    product   = var.product
  }
}


output "bigip2_management_pip" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.bigip2-mgmt.ip_address} pass: ${local.admin_password}"
}
