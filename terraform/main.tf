module "devops" {
  source = "./devops"
  
  compartment_id   = oci_identity_compartment.tf-compartment.id
  compartment_name = oci_identity_compartment.tf-compartment.name
  tenancy_ocid     = var.tenancy_ocid
  
  project_name        = "livekit"
  project_description = "DevOps project for LiveKit agent application"
  
  build_pipeline_params = {
    registry_url      = "${var.region}.ocir.io"
    image_name        = "livekit-agent"
    tenancy_name      = data.oci_identity_tenancy.current_tenancy.name
    user_name         = data.oci_identity_user.current_user.name
    tenancy_namespace = data.oci_objectstorage_namespace.current_namespace.namespace
  }
  
  github_config = {
    username              = "rafanegrette"
    access_token_secret_id = oci_vault_secret.github_pat_secret.id
    repository_url        = "https://github.com/rafanegrette/sophi-livekit"
    branch               = "main"
  }
  
  container_registry = {
    image_uri     = "${var.region}.ocir.io/${data.oci_artifacts_container_configuration.container_configuration.namespace}/${oci_artifacts_container_repository.livekit_repository.display_name}:latest"
    repository_id = oci_artifacts_container_repository.livekit_repository.id
  }
  
  oke_cluster_id = oci_containerengine_cluster.oke-cluster.id
  
  freeform_tags = {
    "Environment" = "development"
    "Project"     = "livekit"
    "OCI_RESOURCE_PRINCIPAL_VERSION" = "2.2"
  }
}
