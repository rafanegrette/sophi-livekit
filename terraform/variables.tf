variable "tenancy_ocid" {
  type        = string
  description = "Tenancy id, account of the oci"
  sensitive   = true
}

variable "user_ocid" {
  type        = string
  description = "User id, owner of resources in oci"
  sensitive   = true
}

variable "private_key_path" {
  type        = string
  description = "Private key path in the host environment"
  sensitive   = true
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint value of the owner of resources in oci"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region host of the resources in oci"
  sensitive   = true
}

variable "github_access_token" {
  type        = string
  description = "GitHub Personal Access Token for repository access"
  sensitive   = true
}
