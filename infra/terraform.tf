terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
      version = "2.9.0"
    }
    dbtcloud = {
      source  = "dbt-labs/dbtcloud"
      version = "~> 1.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}
