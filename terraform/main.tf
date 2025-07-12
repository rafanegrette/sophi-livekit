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
    image_uri     = "${var.region}.ocir.io/${module.oke_cluster.container_registry_url}/${module.oke_cluster.container_repository_name}:latest"
    repository_id = module.oke_cluster.container_repository_id
  }
  
  oke_cluster_id = module.oke_cluster.cluster_id
  
  freeform_tags = {
    "Environment" = "development"
    "Project"     = "livekit"
    "OCI_RESOURCE_PRINCIPAL_VERSION" = "2.2"
  }
}


module "oke_cluster" {
  source = "./oke-cluster"
  
  # General
  compartment_id = oci_identity_compartment.tf-compartment.id
  
  # Cluster configuration
  kubernetes_version = "v1.33.1"
  cluster_name       = "livekit-agent-cluster"
  vcn_id            = module.vcn.vcn_id
  
  # Network configuration
  service_lb_subnet_ids = [oci_core_subnet.vcn-public-subnet.id]
  
  # Node pool configuration
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  private_subnet_id   = oci_core_subnet.vcn-private-subnet.id
  node_image_id       = "ocid1.image.oc1.phx.aaaaaaaaxe2ivqoxeo4c3bgkeutfpod4oklzxmkrxgirgwgft2swftwcni2a"
}
