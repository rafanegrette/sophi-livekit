# Container Registry Repository
resource "oci_artifacts_container_repository" "app_repository" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-${var.environment}"
  is_public      = var.is_public
  readme {
    content = "Container repository for ${var.project_name} ${var.environment} environment"
    format  = "text/markdown"
  }

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# User Group for developers who need OCIR access (must be at tenancy level)
resource "oci_identity_group" "developers" {
  count          = var.create_developer_group ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Developers group for ${var.project_name} ${var.environment}"
  name           = var.developer_group_name

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Dynamic Group for Container Instances (must be at tenancy level)
resource "oci_identity_dynamic_group" "container_instance_group" {
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for container instances in ${var.project_name} ${var.environment}"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
  name           = "${var.project_name}-${var.environment}-container-instance-dg"

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# IAM Policy for OCIR access (must be at tenancy level)
resource "oci_identity_policy" "ocir_policy" {
  compartment_id = var.tenancy_ocid
  description    = "Policy for OCIR access for ${var.project_name} ${var.environment}"
  name           = "${var.project_name}-${var.environment}-ocir-policy"

  # Use locals to build statements to avoid complex conditionals in statements list
  statements = concat(
    [
    "Allow dynamic-group ${oci_identity_dynamic_group.container_instance_group.name} to read repos in compartment id ${var.compartment_ocid}",
      "Allow dynamic-group ${oci_identity_dynamic_group.container_instance_group.name} to use container-image-artifacts in compartment id ${var.compartment_ocid}"
    ],
    var.create_developer_group ? [
      "Allow group ${oci_identity_group.developers[0].name} to manage repos in compartment id ${var.compartment_ocid}",
      "Allow group ${oci_identity_group.developers[0].name} to manage container-image-artifacts in compartment id ${var.compartment_ocid}",
      "Allow group ${oci_identity_group.developers[0].name} to use container-image-artifacts in compartment id ${var.compartment_ocid}"
    ] : [
      "Allow group ${var.developer_group_name} to manage repos in compartment id ${var.compartment_ocid}",
      "Allow group ${var.developer_group_name} to manage container-image-artifacts in compartment id ${var.compartment_ocid}",
      "Allow group ${var.developer_group_name} to use container-image-artifacts in compartment id ${var.compartment_ocid}"
  ]
  )

  depends_on = [
    oci_identity_group.developers,
    oci_identity_dynamic_group.container_instance_group
  ]

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Auth token for programmatic access (optional - use with caution)
resource "oci_identity_auth_token" "ocir_token" {
  count       = var.create_auth_token ? 1 : 0
  user_id     = var.user_ocid
  description = "Auth token for OCIR access - ${var.project_name} ${var.environment}"
}

# Data source to get the namespace
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}
