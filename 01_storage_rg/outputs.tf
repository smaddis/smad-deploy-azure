output "rg_id" {
  value = azurerm_resource_group.storage_rg.id
}

output "rg_name" {
  value = azurerm_resource_group.storage_rg.name
}

output "storage_share_influx" {
  value = azurerm_storage_share.influx_share.name
}

output "storage_share_mongo" {
  value = azurerm_storage_share.mongo_share.name
}
output "storage_share_kafka" {
  value = azurerm_storage_share.kafka_share.name
}
output "storage_share_zookeeper" {
  value = azurerm_storage_share.zookeeper_share.name
}
output "storage_share_hono" {
  value = azurerm_storage_share.hono_share.name
}
output "storage_acc_name" {
  value = azurerm_storage_account.storage_account.name
}
/*
output "storage_acc_id" {
  value = ${azurerm_storage_account.storage_account.identity.0.principal_id}
}
*/
output "storage_acc_key" {
  value     = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}
