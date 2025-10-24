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
  name                         = "csv"
  database                     = snowflake_database.db.name
  schema                       = snowflake_schema.raw.name
  format_type                  = "CSV"
  field_optionally_enclosed_by = "\""
  skip_header                  = 1
}

resource "snowflake_stage" "raw_data" {
  name     = "raw_data"
  database = snowflake_database.db.name
  schema   = snowflake_schema.raw.name
  url      = "s3://dbt-datasets"
  # https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/stage#file_format-2
  file_format = "FORMAT_NAME = ${snowflake_file_format.raw_csv.fully_qualified_name}"
}

resource "snowflake_account_role" "transform" {
  name = "transform"
}

resource "snowflake_grant_privileges_to_account_role" "operate" {
  privileges        = ["OPERATE"]
  account_role_name = snowflake_account_role.transform.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "COMPUTE_WH"
  }
}
