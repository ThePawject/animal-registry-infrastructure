output "server_name" {
  value = azurerm_mssql_server.this.name
}

output "server_id" {
  value = azurerm_mssql_server.this.id
}

output "database_names" {
  value       = [for db in azurerm_mssql_database.databases : db.name]
  description = "List of database names"
}

output "databases" {
  value = {
    for name, db in azurerm_mssql_database.databases :
    name => {
      name = db.name
      id   = db.id
    }
  }
  description = "Map of database details"
}

output "fully_qualified_domain_name" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}
