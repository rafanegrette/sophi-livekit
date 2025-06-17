# Data source to get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Create the compartment
resource "oci_identity_compartment" "main_compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for ${var.project_name} ${var.environment} environment"
  name           = "livekit-agent-compartment"

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Create networking infrastructure
module "networking" {
  source = "./modules/networking"

  tenancy_ocid               = var.tenancy_ocid
  compartment_ocid          = oci_identity_compartment.main_compartment.id
  availability_domain       = var.availability_domain
  project_name              = var.project_name
  environment               = var.environment
  vcn_cidr_block           = var.vcn_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
}

module "ocir" {
  source = "./modules/ocir"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = oci_identity_compartment.main_compartment.id
  project_name            = var.project_name
  environment             = var.environment
  is_public               = var.ocir_is_public
  developer_group_name    = var.developer_group_name
  create_developer_group  = var.create_developer_group
  create_auth_token       = var.create_auth_token
  user_ocid              = var.user_ocid
}