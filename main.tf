variable "environment" {
  description = "The environment to deploy the resources in (e.g., dev, test, staging, prod)"
  type        = string
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "super-enigma-${var.environment}"
  location = "West Europe"
}

resource "azurerm_static_web_app" "webapp" {
  name                = "swa-se-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West Europe"
}

resource "azurerm_user_assigned_identity" "deployer_identity" {
  name                = "se-deployer-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West Europe"
}

resource "azurerm_federated_identity_credential" "github_federation" {
  name                = "deploy-federation-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.deployer_identity.id
  subject             = "repo:akkujii/super-enigma:environment:${var.environment}"
}

data "azurerm_role_definition" "static_web_app_deployer" {
  name  = "Static Web App Deployer Role"
  scope = data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "wa_deployer" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = data.azurerm_role_definition.static_web_app_deployer.id
  principal_id       = azurerm_user_assigned_identity.deployer_identity.principal_id
}
