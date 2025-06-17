variable "compartment_ocid" {
  description = "The OCID of the compartment"
  type        = string
}

variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "is_public" {
  description = "Whether the repository should be public"
  type        = bool
  default     = false
}

variable "developer_group_name" {
  description = "Name of the developer group"
  type        = string
}

variable "create_developer_group" {
  description = "Whether to create a developer group"
  type        = bool
  default     = true
}

variable "create_auth_token" {
  description = "Whether to create an auth token"
  type        = bool
  default     = false
}

variable "user_ocid" {
  description = "User OCID for auth token creation"
  type        = string
  default     = ""
}