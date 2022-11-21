resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-testing-terraform"
  address_space       = var.vnet.address_space
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet.vms.subnet_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.subnet.vms.address_prefixes
}

resource "azurerm_network_interface" "network_interface" {
  name                = "${var.vm_name}_nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group.name


  ip_configuration {
    name                          = "${var.vm_name}_nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                  = var.vm_name
  location              = var.region
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "${var.vm_name}_OsDisk_C"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 256
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}
