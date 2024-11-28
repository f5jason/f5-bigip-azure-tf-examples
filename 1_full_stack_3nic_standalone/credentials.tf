# Generate random password
#
resource "random_string" "password" {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}


resource "random_pet" "password" {
  length = 2
}

locals {
  #admin_password = random_string.password.result
  admin_password = "F5-${random_pet.password.id}"
}


output "admin_password" {
  value = local.admin_password
}

output "admin_username" {
  value = var.admin_username
}


# Generate SSH Keypair
#
resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#resource "azurerm_ssh_public_key" "my_sshkey" {
#  name                = "${var.prefix}_ssh_keypair"
#  location            = azurerm_resource_group.main.location
#  resource_group_name = azurerm_resource_group.main.name
#  public_key          = tls_private_key.my_keypair.public_key_openssh
#}

resource "local_file" "private_key" {
  content         = tls_private_key.my_keypair.private_key_pem
  filename        = "${path.module}/outputs/${var.prefix}_ssh_keypair.key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.my_keypair.public_key_openssh
  filename        = "${path.module}/outputs/${var.prefix}_ssh_keypair.pub"
  file_permission = "0600"
}
