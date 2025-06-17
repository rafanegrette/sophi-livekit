variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "region" {
  description = "The OCI region"
  type        = string
  default     = "us-phoenix-1"
}

variable "availability_domain" {
  description = "The availability domain for resources"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "python-webrtc-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "config_file_profile" {
  description = "Configuration file for OCI provider"
  type        = string
  default     = "DEFAULT"
}

variable "ocir_is_public" {
  description = "Whether the OCIR repository should be public"
  type        = bool
  default     = false
}

variable "developer_group_name" {
  description = "Name of the developer group for OCIR access"
  type        = string
  default     = "ocir-developers"
}

variable "create_developer_group" {
  description = "Whether to create a developer group"
  type        = bool
  default     = true
}

variable "create_auth_token" {
  description = "Whether to create an auth token for programmatic access"
  type        = bool
  default     = false
}

variable "user_ocid" {
  description = "User OCID for auth token creation (required if create_auth_token is true)"
  type        = string
  default     = ""
}
