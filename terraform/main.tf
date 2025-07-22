locals {
  ocir_username = "${data.oci_objectstorage_namespace.current_namespace.namespace}/${data.oci_identity_user.current_user.name}"
}

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
    access_token_secret_id = oci_vault_secret.github_pat_secret3.id
    repository_url        = "https://github.com/rafanegrette/sophi-livekit"
    branch               = "main"
  }

  
  build_config = {
    source_folder   = "voice-pipeline-agent-python"
    timeout_seconds = 3600
    build_spec_file = "voice-pipeline-agent-python/build_spec.yaml"
    compute_shape   = "VM.Standard2.1"
    ocpu            = 1
    memory_in_gbs   = 6
    image           = "OL7_X86_64_STANDARD_10"
  }

  app_secrets = var.app_secrets
  region = var.region
  oke_cluster_id = module.oke_cluster.cluster_id

  freeform_tags = {
    "Environment" = "development"
    "Project"     = "livekit"
    "OCI_RESOURCE_PRINCIPAL_VERSION" = "2.2"
  }
}

# Replace the existing VCN module and individual resources with:
module "network" {
  source = "./network"
  
  compartment_id = oci_identity_compartment.tf-compartment.id
  
  # VCN configuration
  vcn_name      = "livekit-vcn"
  vcn_cidrs     = ["10.0.0.0/16"]
  vcn_dns_label = "livekitvcn"
  
  # Gateway configuration
  create_internet_gateway = true
  create_nat_gateway     = true
  create_service_gateway = true
  
  # Security list names
  public_security_list_name  = "security-list-for-public-subnet"
  private_security_list_name = "security-list-for-private-subnet"
  
  # Subnet configuration
  public_subnet_name   = "public-subnet"
  public_subnet_cidr   = "10.0.0.0/24"
  private_subnet_name  = "private-livekit-subnet"
  private_subnet_cidr  = "10.0.1.0/24"
  
  freeform_tags = {
    "Environment" = "development"
    "Project"     = "livekit"
  }
}

module "oke_cluster" {
  source = "./oke-cluster"
  
  # General
  compartment_id = oci_identity_compartment.tf-compartment.id
  
  # Cluster configuration
  kubernetes_version = "v1.33.1"
  cluster_name       = "livekit-agent-cluster"
  vcn_id            = module.network.vcn_id
  
  # Network configuration
  service_lb_subnet_ids = [module.network.public_subnet_id]
  
  # Node pool configuration
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  private_subnet_id   = module.network.private_subnet_id
  node_image_id       = "ocid1.image.oc1.phx.aaaaaaaaxe2ivqoxeo4c3bgkeutfpod4oklzxmkrxgirgwgft2swftwcni2a"

  app_namespace = "livekit"
  
  region = var.region

  ocir_config = {
    username = local.ocir_username
    auth_token = var.ocir_auth_token
    email = "rafaelnegretteamaya@outlook.com"
  }
}
