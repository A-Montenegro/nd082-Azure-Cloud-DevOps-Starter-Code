terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terra" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_network_security_group" "terra" {
  name                = "${var.prefix}-security"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name
}

resource "azurerm_virtual_network" "terra" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "internal" {
	name = "internal"
	resource_group_name = azurerm_resource_group.terra.name
	virtual_network_name = azurerm_virtual_network.terra.name
	address_prefixes = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "terra" {
  name                = "acceptance${var.prefix}PublicIp1"
  resource_group_name = azurerm_resource_group.terra.name
  location            = azurerm_resource_group.terra.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb" "terra" {
  name                = "${var.prefix}LoadBalancer"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.terra.id
  }
}

data "azurerm_resource_group" "image" {
  name = var.packer_resource_group_name
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_availability_set" "terra" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name
  
  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "terra" {
  count = var.number_of_vms
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.terra.location
  resource_group_name = azurerm_resource_group.terra.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "terra" {
  count = var.number_of_vms
  name                  = "${var.prefix}-virtualmachine-${count.index}"
  location              = azurerm_resource_group.terra.location
  resource_group_name   = azurerm_resource_group.terra.name
  network_interface_ids = [element(azurerm_network_interface.terra.*.id, count.index)]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "terradisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "Admin1986"
    admin_password = "Password1234$"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}


