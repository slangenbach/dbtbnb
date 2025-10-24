provider "snowflake" {
  organization_name        = var.sf_org
  account_name             = var.sf_account
  user                     = var.sf_user
  role                     = var.sf_role
  authenticator            = "SNOWFLAKE_JWT"
  private_key              = file(var.sf_private_key_path)
  preview_features_enabled = ["snowflake_table_resource"]
}
