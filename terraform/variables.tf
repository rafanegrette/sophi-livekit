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

data "oci_identity_tenancy" "current_tenancy" {
    tenancy_id = var.tenancy_ocid
}

data "oci_identity_user" "current_user" {
    user_id = var.user_ocid
}

data "oci_objectstorage_namespace" "current_namespace" {
    compartment_id = oci_identity_compartment.tf-compartment.id
}


variable "app_secrets" {
  description = "Applications secrets"
  type = object({
    livekit_key = string
    livekit_secret = string
    livekit_url = string
    cartesia_api_key = string
    deepgram_api_key = string
    openai_api_key = string
    deepseek_api_key = string
  })
}