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
