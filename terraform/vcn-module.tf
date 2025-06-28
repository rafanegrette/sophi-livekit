module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"
  
  compartment_id = oci_identity_compartment.tf-compartment.id

  region = var.region

  vcn_name = "livekit-vcn"
  create_internet_gateway = true
  create_nat_gateway = true
  create_service_gateway = true

  vcn_dns_label = "livekitapp"
}