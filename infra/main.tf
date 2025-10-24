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
