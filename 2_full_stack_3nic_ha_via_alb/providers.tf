# Providers

# Terraform Version Pinning
terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
  }
}

# Azure Provider
provider "azurerm" {
  features {}
}
