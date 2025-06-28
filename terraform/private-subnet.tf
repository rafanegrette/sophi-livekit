resource "oci_core_subnet" "vcn-private-subnet" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    vcn_id = module.vcn.vcn_id
    cidr_block = "10.0.1.0/24"

    route_table_id = module.vcn.nat_route_id
    security_list_ids = [oci_core_security_list.public-security-list.id]
    display_name = "private-livekit-subnet"
}