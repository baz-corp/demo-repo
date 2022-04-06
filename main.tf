provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test-vm-rg" {
  name     = "testvmrg"
  location = "UK South"
}
########################################
# Data Block
########################################
data "azurerm_subnet" "example" {
  name                 = "default"
  virtual_network_name = "Core_VNET"
  resource_group_name  = "Core_Infrastructure"
}
output "subnet_id" {
  value = data.azurerm_subnet.example.id
}
##########################################

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.test-vm-rg.location
  resource_group_name = azurerm_resource_group.test-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.test-vm-rg.name
  location            = azurerm_resource_group.test-vm-rg.location
  size                = "Standard_B2s"
  source_image_id    = "/subscriptions/27c89005-ab7e-4f81-a306-71e85d680f5e/resourceGroups/vmforiamge/providers/Microsoft.Compute/galleries/bazcomputegallery/images/Gold-Gallery-Image"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  } 
}
 