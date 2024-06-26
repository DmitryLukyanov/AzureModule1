# https://developer.hashicorp.com/terraform/language/syntax/configuration
# connection to azure cloud

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}

provider "azurerm" { 
  #client_id       = ""
  #client_secret   = ""
  tenant_id       = ""
  subscription_id = ""
  features { }
}