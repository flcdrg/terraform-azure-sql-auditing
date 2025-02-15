resource "azurerm_eventhub_namespace" "eh" {
  name                = "evhns-terraform-sql-auditing-australiaeast"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "eh" {
  name = "evh-terraform-sql-auditing-australiaeast"
  # AzureRM v4.x
  namespace_id = azurerm_eventhub_namespace.eh.id

  # AzureRM v3.x
  #resource_group_name = data.azurerm_resource_group.rg.name
  #namespace_name      = azurerm_eventhub_namespace.eh.name
  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "eh" {
  name                = "evhar-terraform-sql-auditing-australiaeast"
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}
