output "db_name" {
  description = "Database name"
  value       = snowflake_database.db.name
}

output "raw_schema_name" {
  description = "Schema name for raw data"
  value       = snowflake_schema.raw.name
}

output "raw_stage_name" {
  description = "Stage to copy raw data from"
  value       = snowflake_stage.raw_data.name
}

output "raw_file_format" {
  description = "File format used to copy raw data"
  value       = snowflake_file_format.raw_csv.fully_qualified_name
}
