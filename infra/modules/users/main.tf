# Transform role
resource "snowflake_account_role" "transform" {
  name = "TRANSFORM"
}

resource "snowflake_grant_account_role" "transform_to_security_admin" {
  role_name        = snowflake_account_role.transform.name
  parent_role_name = "SECURITYADMIN"
}

resource "snowflake_grant_privileges_to_account_role" "operate_to_transform" {
  privileges        = ["OPERATE"]
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

# DBT user
resource "snowflake_service_user" "dbt" {
  name              = "dbt"
  login_name        = "dbt"
  rsa_public_key    = file(var.user_public_key_path)
  default_role      = snowflake_account_role.transform.name
  default_warehouse = "COMPUTE_WH"
  default_namespace = var.dbt_default_namespace
  comment           = "DBT user for data transformation"
}

resource "snowflake_grant_account_role" "transform_to_dbt" {
  role_name = snowflake_account_role.transform.name
  user_name = snowflake_service_user.dbt.name
}

resource "snowflake_grant_privileges_to_account_role" "all_on_warehouse_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_on_db_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "DATABASE"
    object_name = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_on_all_schemas_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema {
    all_schemas_in_database = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_on_future_schemas_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema {
    future_schemas_in_database = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_on_all_tables_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = var.dbt_default_namespace
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "all_on_all_future_tables_to_transform" {
  all_privileges    = true
  account_role_name = snowflake_account_role.transform.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = var.dbt_default_namespace
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
  rsa_public_key    = file(var.user_public_key_path)
  default_role      = snowflake_account_role.reporter.name
  default_warehouse = "COMPUTE_WH"
  default_namespace = var.preset_default_namespace
  comment           = "Preset user to create reports"
}

resource "snowflake_grant_account_role" "reporter_to_preset" {
  role_name = snowflake_account_role.reporter.name
  user_name = snowflake_service_user.preset.name
}

resource "snowflake_grant_account_role" "reporter_to_security_admin" {
  role_name        = snowflake_account_role.reporter.name
  parent_role_name = "SECURITYADMIN"
}

resource "snowflake_grant_privileges_to_account_role" "all_on_wh_to_reporter" {
  all_privileges    = true
  account_role_name = snowflake_account_role.reporter.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_on_db_to_reporter" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.reporter.name
  on_account_object {
    object_type = "DATABASE"
    object_name = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_on_all_schemas_to_reporter" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema {
    all_schemas_in_database = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "usage_on_future_schemas_to_reporter" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema {
    future_schemas_in_database = var.default_db
  }
}

resource "snowflake_grant_privileges_to_account_role" "select_on_all_tables_to_reporter" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = var.preset_default_namespace
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "select_on_all_future_tables_to_reporter" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.reporter.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = var.preset_default_namespace
    }
  }
}
