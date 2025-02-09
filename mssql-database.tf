resource "azurerm_mssql_database" "primary" {
  name           = "sqldb-terraform-sql-auditing-australiaeast"
  server_id      = azurerm_mssql_server.mssql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"
  max_size_gb    = 1
  zone_redundant = false
  sample_name    = "AdventureWorksLT"
}
