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

# Agent role
resource "snowflake_account_role" "agent" {
  name = "AGENT"
}

# Streamlit user
resource "snowflake_service_user" "streamlit" {
  name              = "streamlit"
  login_name        = "streamlit"
  rsa_public_key    = file(var.streamlit_public_key_path)
  default_role      = snowflake_account_role.agent.name
  default_warehouse = "COMPUTE_WH"
  default_namespace = var.streamlit_default_namespace
  comment           = "Streamlit user to run dashboards"
}

resource "snowflake_grant_account_role" "agent_to_streamlit" {
  role_name = snowflake_account_role.agent.name
  user_name = snowflake_service_user.streamlit.name
}

resource "snowflake_grant_account_role" "agent_to_sysadmin" {
  role_name        = snowflake_account_role.agent.name
  parent_role_name = "SYSADMIN"
}


# Agent grants - Cortex User role
resource "snowflake_grant_database_role" "cortex_user_to_agent" {
  database_role_name = "SNOWFLAKE.CORTEX_USER"
  parent_role_name   = snowflake_account_role.agent.name
}

# Agents  grants - Warehouse
resource "snowflake_grant_privileges_to_account_role" "warehouse_to_agent" {
  privileges        = ["USAGE", "OPERATE"]
  account_role_name = snowflake_account_role.agent.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}

# Agent grants - Database
resource "snowflake_grant_privileges_to_account_role" "database_to_agent" {
  account_role_name = snowflake_account_role.agent.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.default_db
  }
}

# Agent grants - Schema
resource "snowflake_grant_privileges_to_account_role" "schema_to_agent" {
  account_role_name = snowflake_account_role.agent.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = var.streamlit_default_namespace
  }
}

# Agent grants - Semantic Model Access
resource "snowflake_grant_privileges_to_account_role" "semantic_model_to_agent" {
  account_role_name = snowflake_account_role.agent.name
  privileges        = ["SELECT"]
  on_schema_object {
    object_type = "VIEW"
    object_name = "${var.streamlit_default_namespace}.AIRBNB"
  }
}
