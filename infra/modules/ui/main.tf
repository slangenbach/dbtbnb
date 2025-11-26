resource "snowflake_streamlit" "app" {
  name      = var.app_name
  database  = var.sf_database
  schema    = var.sf_schema
  stage     = var.sf_stage
  main_file = var.main_file_path
}
