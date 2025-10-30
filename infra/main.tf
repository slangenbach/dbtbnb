module "database" {
  source              = "./modules/database"
  sf_org              = var.sf_org
  sf_account          = var.sf_account
  sf_user             = var.sf_user
  sf_private_key_path = var.sf_private_key_path
}

module "users" {
  source                   = "./modules/users"
  sf_org                   = var.sf_org
  sf_account               = var.sf_account
  sf_user                  = var.sf_user
  sf_private_key_path      = var.sf_private_key_path
  dbt_public_key_path      = var.dbt_public_key_path
  preset_public_key_path   = var.preset_public_key_path
  default_db               = module.database.db_name
  dbt_default_namespace    = module.database.raw_schema_fqdn
  preset_default_namespace = module.database.dev_schema_fqdn
}
