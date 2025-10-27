provider "snowflake" {
  organization_name = var.sf_org
  account_name      = var.sf_account
  user              = var.sf_user
  role              = "SECURITYADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(var.sf_private_key_path)
}
