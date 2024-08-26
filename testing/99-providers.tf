////////////////////////
// Terraform Configuration
////////////////////////

terraform {

  required_version = ">= 1.8.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.53.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

////////////////////////
// Provider Configuration
////////////////////////

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}
