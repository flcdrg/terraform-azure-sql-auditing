resource "random_string" "storage_suffix" {
  numeric = true
  special = false
  length  = 3
  upper   = false
}

resource "azurerm_storage_account" "storage" {
  name                             = "sttfsqlauditaue${random_string.storage_suffix.result}"
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = data.azurerm_resource_group.rg.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

# Required for using Managed Identity to authenticate to the Storage Account
resource "azurerm_role_assignment" "mssql_has_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.mssql.identity[0].principal_id
}
