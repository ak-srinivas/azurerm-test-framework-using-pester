region              = "eastus2"
admin_username      = "autobotadmin"
admin_password      = "Getbusyliving@1"
resource_group_name = "azurerm_test_using_pester_rg"
vm_name             = "autobotvm000001"

azure_subscription_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

vnet = {
  address_space = ["10.0.4.0/24"]
}

subnet = {
  vms = {
    subnet_name      = "subnet_1"
    address_prefixes = ["10.0.4.0/27"]
  }
}
