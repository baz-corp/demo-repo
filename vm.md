resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_network_interface" "azvm1nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "tftest" {
  name                  = "myazurevm"  
  location              = "eastus"
  resource_group_name   = "myresource-rg"
  network_interface_ids = [azurerm_network_interface.azvm1nic.id]
  size               = "Standard_B1s"

  storage_image_reference {
    id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/xxxxx/providers/Microsoft.Compute/images/mytemplate"
  }

  storage_os_disk {
    name              = "my-os-disk"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "my-data-disk"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 75
    create_option     = "FromImage"
    lun               = 0
  }

  os_profile {
    computer_name  = "myvmazure"
    admin_username = "admin"
    admin_password = "test123"
  }

  os_profile_windows_config {
      provision_vm_agent = true
  }
} 