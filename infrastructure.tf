variable "environment" {
  description = "The environment to deploy the resources in (e.g., dev, test, staging, prod)"
  type        = string
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "super-enigma-${var.environment}"
  location = "West Europe"
}

resource "azurerm_static_site" "example" {
  name                = "swa-se-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = "West Europe"
  sku                 = "Free"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "se-deployer-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = "West Europe"
}

resource "azurerm_user_assigned_identity_federated_credential" "example" {
  name                = "deploy-federation-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.example.id
  subject             = "repo:akkujii/super-enigma:environment:${var.environment}"
}

data "azurerm_role_definition" "static_web_app_deployer" {
  name  = "Static Web App Deployers Role"
  scope = data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "example" {
  name               = "static-web-app-deployer-role-assignment"
  scope              = azurerm_resource_group.example.id
  role_definition_id = data.azurerm_role_definition.static_web_app_deployer.id
  principal_id       = azurerm_user_assigned_identity.example.principal_id
}
