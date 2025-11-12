output "db_name" {
  description = "Database name"
  value       = module.database.db_name
}

output "raw_schema_name" {
  description = "Schema name for raw data"
  value       = module.database.raw_schema_name
}

output "raw_stage_name" {
  description = "Stage to copy raw data from"
  value       = module.database.raw_stage_name
}

output "raw_file_format" {
  description = "File format used to copy raw data"
  value       = module.database.raw_file_format_name
}

output "sf_account" {
  description = "Snowflake account incl. Snowflake organization"
  value       = "${var.sf_org}-${var.sf_account}"
}

output "preset_user" {
  description = "Name of Preset user"
  value       = module.users.preset_user
}

output "preset_role" {
  description = "Role of preset user"
  value       = module.users.preset_role
}

output "preset_private_key_path" {
  description = "Path to private key for preset user"
  value       = var.preset_private_key_path
}
