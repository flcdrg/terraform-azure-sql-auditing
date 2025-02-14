# Use this if you just want Auditing for Log Analytics and/or Event Hub
# resource "azurerm_mssql_server_extended_auditing_policy" "auditing" {
#   server_id = azurerm_mssql_server.mssql.id

#   depends_on = [azurerm_monitor_diagnostic_setting.mssql_server]
# }

# Use Storage Account for Extended Auditing
# resource "azurerm_mssql_server_extended_auditing_policy" "auditing" {
#   server_id = azurerm_mssql_server.mssql.id

#   storage_endpoint                        = azurerm_storage_account.storage.primary_blob_endpoint
#   storage_account_access_key              = azurerm_storage_account.storage.primary_access_key
#   storage_account_access_key_is_secondary = false
#   retention_in_days                       = 6
# }

# Use Storage Account for Extended Auditing, with managed identity authentication
resource "azurerm_mssql_server_extended_auditing_policy" "auditing" {
  server_id = azurerm_mssql_server.mssql.id

  storage_endpoint  = azurerm_storage_account.storage.primary_blob_endpoint
  retention_in_days = 6

  depends_on = [azurerm_monitor_diagnostic_setting.mssql_server]
}

# Watch out for https://github.com/hashicorp/terraform-provider-azurerm/issues/22226,

# resource "azurerm_monitor_diagnostic_setting" "mssql_server" {
#   name                       = "diagnostic_setting"
#   target_resource_id         = "${azurerm_mssql_server.mssql.id}/databases/master"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

#   enabled_log {
#     category = "SQLSecurityAuditEvents"
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "mssql_server" {
#   name                           = "diagnostic_setting"
#   target_resource_id             = "${azurerm_mssql_server.mssql.id}/databases/master"
#   eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.eh.id
#   eventhub_name                  = azurerm_eventhub.eh.name

#   enabled_log {
#     category = "SQLSecurityAuditEvents"
#   }
# }

resource "azurerm_monitor_diagnostic_setting" "mssql_server" {
  name                           = "diagnostic_setting"
  target_resource_id             = "${azurerm_mssql_server.mssql.id}/databases/master"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.eh.id
  eventhub_name                  = azurerm_eventhub.eh.name

  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  #storage_account_id         = azurerm_storage_account.storage.id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  depends_on = [
    # Wait for master database to be created. Workaround for https://github.com/hashicorp/terraform-provider-azurerm/issues/22226
    azurerm_mssql_database.primary,
    # Ensure role assignment exists first (for Managed Identity access to Storage Account)
    azurerm_role_assignment.mssql_has_storage_blob_data_contributor
  ]

  # lifecycle {
  #   // Mitigate https://github.com/hashicorp/terraform-provider-azurerm/issues/10388 and https://github.com/hashicorp/terraform-provider-azurerm/issues/17779
  #   ignore_changes = [enabled_log, metric, log_analytics_destination_type]
  # }
}
