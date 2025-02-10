resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-terraform-sql-auditing-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
}