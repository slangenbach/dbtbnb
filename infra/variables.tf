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

variable "sf_public_key_path" {
  description = "Path to public key file to authenticate with Snowflake"
  type        = string
}

variable "dbt_private_key_path" {
  description = "Path to private key file to authenticate with dbt with Snowflake"
  type        = string
}

variable "dbt_public_key_path" {
  description = "Path to public key file to authenticate with dbt with Snowflake"
  type        = string
}

variable "preset_private_key_path" {
  description = "Path to private key file to authenticate with Preset with Snowflake"
  type        = string
}

variable "preset_public_key_path" {
  description = "Path to public key file to authenticate with Preset with Snowflake"
  type        = string
}
