locals {
  raw_table_names = ["RAW_LISTINGS", "RAW_REVIEWS", "RAW_HOSTS"]
}

resource "snowflake_database" "db" {
  name = "AIRBNB"
}

resource "snowflake_schema" "raw" {
  name     = "RAW"
  database = snowflake_database.db.name
}

resource "snowflake_schema" "dev" {
  name     = "DEV"
  database = snowflake_database.db.name
}

resource "snowflake_table" "raw_listings" {
  name     = "RAW_LISTINGS"
  database = snowflake_database.db.name
  schema   = snowflake_schema.raw.name

  column {
    name = "ID"
    type = "STRING"
  }

  column {
    name = "LISTING_URL"
    type = "STRING"
  }

  column {
    name = "NAME"
    type = "STRING"
  }

  column {
    name = "ROOM_TYPE"
    type = "STRING"
  }

  column {
    name = "MINIMUM_NIGHTS"
    type = "INTEGER"
  }

  column {
    name = "HOST_ID"
    type = "INTEGER"
  }

  column {
    name = "PRICE"
    type = "STRING"
  }

  column {
    name = "CREATED_AT"
    type = "DATETIME"
  }

  column {
    name = "UPDATED_AT"
    type = "DATETIME"
  }
}

resource "snowflake_table" "raw_reviews" {
  name     = "RAW_REVIEWS"
  database = snowflake_database.db.name
  schema   = snowflake_schema.raw.name

  column {
    name = "ID"
    type = "INTEGER"
  }

  column {
    name = "DATE"
    type = "DATETIME"
  }

  column {
    name = "REVIEWER_NAME"
    type = "STRING"
  }

  column {
    name = "COMMENTS"
    type = "STRING"
  }

  column {
    name = "SENTIMENT"
    type = "STRING"
  }
}

resource "snowflake_table" "raw_hosts" {
  name     = "RAW_HOSTS"
  database = snowflake_database.db.name
  schema   = snowflake_schema.raw.name

  column {
    name = "ID"
    type = "INTEGER"
  }

  column {
    name = "NAME"
    type = "STRING"
  }

  column {
    name = "IS_SUPERHOST"
    type = "STRING"
  }

  column {
    name = "CREATED_AT"
    type = "DATETIME"
  }

  column {
    name = "UPDATED_AT"
    type = "DATETIME"
  }
}

resource "snowflake_file_format" "raw_csv" {
  name                         = "RAW_CSV"
  database                     = snowflake_database.db.name
  schema                       = snowflake_schema.raw.name
  format_type                  = "CSV"
  field_optionally_enclosed_by = "\""
  skip_header                  = 1
}

resource "snowflake_stage" "raw_data" {
  name     = "RAW_DATA"
  database = snowflake_database.db.name
  schema   = snowflake_schema.raw.name
  url      = "s3://dbt-datasets"
  # https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/stage#file_format-2
  file_format = "FORMAT_NAME = ${snowflake_file_format.raw_csv.fully_qualified_name}"
}

module "users" {
  source              = "./modules/users"
  sf_org              = var.sf_org
  sf_account          = var.sf_account
  sf_user             = var.sf_user
  sf_private_key_path = var.sf_private_key_path
  # TODO: Create and use key for users
  user_public_key_path     = var.sf_public_key_path
  default_db               = snowflake_database.db.name
  dbt_default_namespace    = snowflake_schema.raw.fully_qualified_name
  preset_default_namespace = snowflake_schema.dev.fully_qualified_name
}
