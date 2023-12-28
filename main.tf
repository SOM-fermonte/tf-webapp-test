# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

# Generate a random integer to create a globally unique name
# resource "random_integer" "ri" {
#   min = 10000
#   max = 99999
# }

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-dev"
  location = "eastus"
}

# Create the Windows App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "asp-terraform-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "S1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_windows_web_app" "webapp" {
  name                  = "app-terraform-dev"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
    application_stack {
        current_stack         = "dotnet"
        dotnet_version        = "v6.0"
    }
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_windows_web_app.webapp.id
  repo_url           = "https://github.com/SOM-fermonte/app-service-web-html-get-started.git"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}