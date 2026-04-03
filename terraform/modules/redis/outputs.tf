# Redis Module - Outputs

output "redis_id" {
  description = "ID of the Redis cache"
  value       = azurerm_redis_cache.main.id
}

output "redis_name" {
  description = "Name of the Redis cache"
  value       = azurerm_redis_cache.main.name
}

output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_port" {
  description = "Port of the Redis cache"
  value       = azurerm_redis_cache.main.port
}

output "redis_primary_key" {
  description = "Primary access key of the Redis cache"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "redis_secondary_key" {
  description = "Secondary access key of the Redis cache"
  value       = azurerm_redis_cache.main.secondary_access_key
  sensitive   = true
}

output "redis_connection_string" {
  description = "Connection string for Redis cache (StackExchange.Redis format)"
  value       = "${azurerm_redis_cache.main.hostname}:${azurerm_redis_cache.main.port},password=${azurerm_redis_cache.main.primary_access_key},ssl=True"
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.redis.id
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = azurerm_private_dns_zone.redis.id
}

output "redis_fqdn" {
  description = "FQDN of the Redis cache via private endpoint"
  value       = azurerm_private_dns_a_record.redis.fqdn
}
