# VCN Module (keeping existing structure)
module "vcn" {
  source = "oracle-terraform-modules/vcn/oci"
  
  compartment_id = var.compartment_id
  
  # VCN configuration
  vcn_name     = var.vcn_name
  vcn_cidrs    = var.vcn_cidrs
  vcn_dns_label = var.vcn_dns_label
  
  # Gateway configuration
  create_internet_gateway = var.create_internet_gateway
  create_nat_gateway     = var.create_nat_gateway
  create_service_gateway = var.create_service_gateway
  
  freeform_tags = var.freeform_tags
}

# Public Security List
resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = var.public_security_list_name

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "1"

    icmp_options {
      type = 3
    }
  }
}

# Private Security List
resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = var.private_security_list_name

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "1"

    icmp_options {
      type = 3
    }
  }
}

# Public Subnet
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = var.public_subnet_cidr
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public_security_list.id]
  display_name      = var.public_subnet_name
}

# Private Subnet
resource "oci_core_subnet" "private_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = module.vcn.vcn_id
  cidr_block        = var.private_subnet_cidr
  route_table_id    = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.public_security_list.id]
  display_name      = var.private_subnet_name
}