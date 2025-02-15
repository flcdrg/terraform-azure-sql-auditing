terraform {
  required_version = ">=1.10.4"

  cloud {

    organization = "flcdrg"

    workspaces {
      name = "terraform-azure-sql-auditing"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0, < 4.0.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "2.2.0"
    }
  }
}


provider "azurerm" {
  features {
    application_insights {
      disable_generated_rule = true
    }

    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }
}
