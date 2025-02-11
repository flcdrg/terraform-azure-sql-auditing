# This doesn't create the correctly named solution, and doesn't include the containedResources

# resource "azurerm_log_analytics_solution" "example" {
#   solution_name         = "SQLAuditing"
#   location              = data.azurerm_resource_group.rg.location
#   resource_group_name   = data.azurerm_resource_group.rg.name
#   workspace_resource_id = azurerm_log_analytics_workspace.la.id
#   workspace_name        = azurerm_log_analytics_workspace.la.name

#   plan {
#     publisher = "Microsoft"
#     product   = "SQLAuditing"

#   }

#   depends_on = [azurerm_monitor_diagnostic_setting.mssql_server]
# }

resource "azapi_resource" "symbolicname" {
  type      = "Microsoft.OperationsManagement/solutions@2015-11-01-preview"
  name      = "SQLAuditing[${azurerm_log_analytics_workspace.la.name}]"
  location  = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id

  tags = {}
  body = {
    plan = {
      name          = "SQLAuditing[${azurerm_log_analytics_workspace.la.name}]"
      product       = "SQLAuditing"
      promotionCode = ""
      publisher     = "Microsoft"
    }
    properties = {
      containedResources = [
        "${azurerm_log_analytics_workspace.la.id}/views/SQLSecurityInsights",
        "${azurerm_log_analytics_workspace.la.id}/views/SQLAccessToSensitiveData"
      ]
      referencedResources = []
      workspaceResourceId = azurerm_log_analytics_workspace.la.id
    }
  }
}
