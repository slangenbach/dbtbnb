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
