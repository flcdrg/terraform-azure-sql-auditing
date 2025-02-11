resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "SQLAuditing"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.la.id
  workspace_name        = azurerm_log_analytics_workspace.la.name

  plan {
    publisher = "Microsoft"
    product   = "SQLAuditing"
  }

  depends_on = [azurerm_monitor_diagnostic_setting.mssql_server]
}
