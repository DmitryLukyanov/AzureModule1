variable "resource_name_prefix" {
  description = "A prefix used for all resource names to ensure uniqueness"
  type        = string
  default     = "learning" # Updated from "example" to "learning"
}

resource "azurerm_resource_group" "learning" {
  name     = "${var.resource_name_prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "learning" {
  name                = "${var.resource_name_prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.learning.location
  resource_group_name = azurerm_resource_group.learning.name
}

resource "azurerm_subnet" "learning" {
  name                 = "${var.resource_name_prefix}-internal"
  resource_group_name  = azurerm_resource_group.learning.name
  virtual_network_name = azurerm_virtual_network.learning.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "learning" {
  name                 = "${var.resource_name_prefix}-learningublicip"
  resource_group_name  = azurerm_resource_group.learning.name
  location             = azurerm_resource_group.learning.location
  allocation_method    = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "learning" {
  name                = "${var.resource_name_prefix}-nic"
  location            = azurerm_resource_group.learning.location
  resource_group_name = azurerm_resource_group.learning.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.learning.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.learning.id
  }
}

resource "azurerm_linux_virtual_machine" "learning" {
  name                  = "${var.resource_name_prefix}-machine"
  resource_group_name   = azurerm_resource_group.learning.name
  location              = azurerm_resource_group.learning.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.learning.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("vm.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "public_ip_value" {
  value = azurerm_public_ip.learning.ip_address
}
