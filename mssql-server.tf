resource "random_password" "password" {
  length           = 32
  override_special = "!#%&*()-_=+[]{}<>:?"
}

resource "azurerm_mssql_server" "mssql" {
  name                          = "sql-terraform-sql-auditing-australiaeast"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  minimum_tls_version           = "1.2"
  version                       = "12.0"
  administrator_login           = var.mssql_administrator_login
  administrator_login_password  = random_password.password.result
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.mssql_azuread_administrator_object_id
  }
}

# Can't have this if public_network_access_enabled is false
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.mssql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Use this if you just want Auditing for Log Analytics and/or Event Hub
# resource "azurerm_mssql_server_extended_auditing_policy" "auditing" {
#   server_id = azurerm_mssql_server.mssql.id
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
#   eventhub_name                  = azurerm_eventhub_namespace.eh.name

#   enabled_log {
#     category = "SQLSecurityAuditEvents"
#   }
# }

resource "azurerm_monitor_diagnostic_setting" "mssql_server" {
  name                           = "diagnostic_setting"
  target_resource_id             = "${azurerm_mssql_server.mssql.id}/databases/master"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.eh.id
  eventhub_name                  = azurerm_eventhub.eh.name

  log_analytics_workspace_id     = azurerm_log_analytics_workspace.la.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  depends_on = [
    # Wait for master database to be created. Workaround for https://github.com/hashicorp/terraform-provider-azurerm/issues/22226
    azurerm_mssql_database.primary,
    # Ensure role assignment exists first (for Managed Identity access to Storage Account)
    azurerm_role_assignment.mssql_has_storage_blob_data_contributor
  ]

  lifecycle {
    // Mitigate https://github.com/hashicorp/terraform-provider-azurerm/issues/10388 and https://github.com/hashicorp/terraform-provider-azurerm/issues/17779
    ignore_changes = [enabled_log, metric, log_analytics_destination_type]
  }
}
