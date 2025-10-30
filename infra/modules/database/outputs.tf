output "db_name" {
  description = "Name of Snowflake database"
  value       = snowflake_database.db.name
}

output "raw_schema_name" {
  description = "Name of raw schema"
  value       = snowflake_schema.raw.name
}

output "raw_schema_fqdn" {
  description = "Fully qualified name of raw schema"
  value       = snowflake_schema.raw.fully_qualified_name
}

output "dev_schema_name" {
  description = "Name of dev schema"
  value       = snowflake_schema.dev.name
}

output "dev_schema_fqdn" {
  description = "Fully qualified name of dev schema"
  value       = snowflake_schema.dev.fully_qualified_name
}

output "raw_stage_name" {
  description = "Name of stage for raw data"
  value       = snowflake_stage.raw_data.name
}

output "raw_file_format_name" {
  description = "Name of the file format used for raw data"
  value       = snowflake_file_format.raw_csv.name
}
