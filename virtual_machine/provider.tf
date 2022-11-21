terraform {
  required_providers {
    #Define the azurerm minimum version and source
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.9.0"
    }
  }

  #Define the minimum terraform version
  required_version = "=1.1.7"
}

provider "azurerm" {
  #Use the subscription id defined in our terraform variables files.
  subscription_id = var.azure_subscription_id
  features {} #This empty block is required for some reason. :)
}
