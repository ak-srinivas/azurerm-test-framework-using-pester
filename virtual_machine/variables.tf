variable "region" {
  type        = string
  description = "Declare the azure region for your resources."
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "Declare the resource group for this environment"
}

variable "vm_name" {
  type        = string
  description = "Declare name of vm"
}

variable "vnet" {
  type = object({
    address_space = list(string)
  })
}

variable "subnet" {
  type = map(object({
    subnet_name      = string
    address_prefixes = list(string)
  }))
  description = "Provide an object with the subnet type name and ip range"
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
  sensitive   = false
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
  sensitive   = true
}
