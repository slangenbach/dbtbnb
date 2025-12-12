variable "sf_org" {
  description = "Snowflake organization name"
  type        = string
}

variable "sf_account" {
  description = "Snowflake account name"
  type        = string
}

variable "sf_user" {
  description = "Snowflake user name"
  type        = string
}

variable "sf_private_key_path" {
  description = "Path to private key file to authenticate with Snowflake"
  type        = string
}

variable "dbt_public_key_path" {
  description = "Path to public key file to authenticate dbt service user with Snowflake"
  type        = string
}

variable "preset_public_key_path" {
  description = "Path to public key file to authenticate preset service user with Snowflake"
  type        = string
}

variable "streamlit_public_key_path" {
  description = "Path to public key file to authenticate Streamlit service user with Snowflake"
  type        = string
}

variable "default_db" {
  description = "Default database"
  type        = string
}

variable "dbt_default_namespace" {
  description = "Default namespace for dbt user"
  type        = string
}

variable "preset_default_namespace" {
  description = "Default namespace for preset user"
  type        = string
}

variable "streamlit_default_namespace" {
  description = "Default namespace for Streamlit user"
  type        = string
}
