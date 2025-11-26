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

variable "sf_database" {
  description = "Snowflake database"
  type        = string
}

variable "sf_schema" {
  description = "Snowflake schema"
  type        = string
}

variable "sf_stage" {
  description = "Snowflake stage"
  type        = string
}

variable "app_name" {
  description = "Streamlit app name"
  type        = string
  default     = "dbtbnb"
}

variable "main_file_path" {
  description = "Path to Streamlit main file"
  type        = string
}
