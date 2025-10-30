locals {
  transform_warehouse_privileges = ["USAGE", "OPERATE", "MODIFY", "MONITOR"]
  transform_database_privileges  = ["USAGE", "CREATE SCHEMA", "MODIFY", "MONITOR"]
  transform_schema_privileges    = ["USAGE", "CREATE TABLE", "CREATE VIEW", "MODIFY", "MONITOR"]

  reporter_warehouse_privileges = ["USAGE", "OPERATE"]
  reporter_database_privileges  = ["USAGE"]
  reporter_schema_privileges    = ["USAGE"]

  object_types = ["TABLES", "VIEWS"]
}

# Transform role
resource "snowflake_account_role" "transform" {
  name = "TRANSFORM"
}

resource "snowflake_grant_account_role" "transform_to_sysadmin" {
  role_name        = snowflake_account_role.transform.name
  parent_role_name = "SYSADMIN"
}

# DBT user
resource "snowflake_service_user" "dbt" {
  name              = "dbt"
  login_name        = "dbt"
  rsa_public_key    = file(var.dbt_public_key_path)
  default_role      = snowflake_account_role.transform.name
  default_warehouse = "COMPUTE_WH"
  default_namespace = var.dbt_default_namespace
  comment           = "DBT user for data transformation"
}

resource "snowflake_grant_account_role" "transform_to_dbt" {
  role_name = snowflake_account_role.transform.name
  user_name = snowflake_service_user.dbt.name
}

# Transform grants - Warehouse
resource "snowflake_grant_privileges_to_account_role" "warehouse_to_transform" {
  privileges        = local.transform_warehouse_privileges
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

# Transform grants - Database
resource "snowflake_grant_privileges_to_account_role" "database_to_transform" {
  privileges        = local.transform_database_privileges
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "DATABASE"
    object_name = var.default_db
  }
}

# Transform grants - Schemas (all existing)
resource "snowflake_grant_privileges_to_account_role" "schemas_to_transform" {
  privileges        = local.transform_schema_privileges
  account_role_name = snowflake_account_role.transform.name
  on_schema {
    all_schemas_in_database = var.default_db
  }
}

# Transform grants - Schemas (future)
resource "snowflake_grant_privileges_to_account_role" "future_schemas_to_transform" {
  privileges        = local.transform_schema_privileges
  account_role_name = snowflake_account_role.transform.name
  on_schema {
    future_schemas_in_database = var.default_db
  }
}

# Transform grants - Objects (all existing)
resource "snowflake_grant_privileges_to_account_role" "objects_to_transform" {
  for_each = toset(local.object_types)

  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema_object {
    all {
      object_type_plural = each.value
      in_database        = var.default_db
    }
  }
}

# Transform grants - Objects (future)
resource "snowflake_grant_privileges_to_account_role" "future_objects_to_transform" {
  for_each = toset(local.object_types)

  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema_object {
    future {
      object_type_plural = each.value
      in_database        = var.default_db
    }
  }
}

# Reporter role
resource "snowflake_account_role" "reporter" {
  name = "REPORTER"
}

resource "snowflake_service_user" "preset" {
  name              = "preset"
  login_name        = "preset"
  rsa_public_key    = file(var.preset_public_key_path)
  default_role      = snowflake_account_role.reporter.name
  default_warehouse = "COMPUTE_WH"
  default_namespace = var.preset_default_namespace
  comment           = "Preset user to create reports"
}

resource "snowflake_grant_account_role" "reporter_to_preset" {
  role_name = snowflake_account_role.reporter.name
  user_name = snowflake_service_user.preset.name
}

resource "snowflake_grant_account_role" "reporter_to_sysadmin" {
  role_name        = snowflake_account_role.reporter.name
  parent_role_name = "SYSADMIN"
}

# Reporter grants - Warehouse
resource "snowflake_grant_privileges_to_account_role" "warehouse_to_reporter" {
  privileges        = local.reporter_warehouse_privileges
  account_role_name = snowflake_account_role.reporter.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

# Reporter grants - Database
resource "snowflake_grant_privileges_to_account_role" "database_to_reporter" {
  privileges        = local.reporter_database_privileges
  account_role_name = snowflake_account_role.reporter.name
  on_account_object {
    object_type = "DATABASE"
    object_name = var.default_db
  }
}

# Reporter grants - Schemas (all existing)
resource "snowflake_grant_privileges_to_account_role" "schemas_to_reporter" {
  privileges        = local.reporter_schema_privileges
  account_role_name = snowflake_account_role.reporter.name
  on_schema {
    all_schemas_in_database = var.default_db
  }
}

# Reporter grants - Schemas (future)
resource "snowflake_grant_privileges_to_account_role" "future_schemas_to_reporter" {
  privileges        = local.reporter_schema_privileges
  account_role_name = snowflake_account_role.reporter.name
  on_schema {
    future_schemas_in_database = var.default_db
  }
}

# Reporter grants - Objects (all existing)
resource "snowflake_grant_privileges_to_account_role" "objects_to_reporter" {
  for_each = toset(local.object_types)

  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema_object {
    all {
      object_type_plural = each.value
      in_database        = var.default_db
    }
  }
}

# Reporter grants - Objects (future)
resource "snowflake_grant_privileges_to_account_role" "future_objects_to_reporter" {
  for_each = toset(local.object_types)

  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema_object {
    future {
      object_type_plural = each.value
      in_database        = var.default_db
    }
  }
}
