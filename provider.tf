terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.18.0"
    }
  }
}
provider "azurerm" {

  features {}
  client_id       = "your client id"
  client_secret   = var.client_secret
  tenant_id       = "your tenant id"
  subscription_id = "your subscription id"
}