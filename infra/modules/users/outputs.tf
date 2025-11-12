output "preset_user" {
  description = "Name of preset user"
  value       = snowflake_service_user.preset.name
}

output "preset_role" {
  description = "Name of role for preset user"
  value       = snowflake_account_role.reporter.name
}
