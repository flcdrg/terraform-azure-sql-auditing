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

resource "azurerm_mssql_server_extended_auditing_policy" "auditing" {
  server_id = azurerm_mssql_server.mssql.id
}

resource "azurerm_monitor_diagnostic_setting" "mssql_server_to_log_analytics" {
  name                       = "example-diagnostic-setting"
  target_resource_id         = "${azurerm_mssql_server.mssql.id}/databases/master"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }
}