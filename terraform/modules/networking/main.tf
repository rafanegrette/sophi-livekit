# Virtual Cloud Network
resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = "${var.project_name}-${var.environment}-vcn"
  dns_label      = "${replace(var.project_name, "-", "")}"
  
  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "main_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "${var.project_name}-${var.environment}-ig"
  enabled        = true

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Route Table for Public Subnet
resource "oci_core_default_route_table" "public_route_table" {
  manage_default_resource_id = oci_core_vcn.main_vcn.default_route_table_id
  display_name              = "${var.project_name}-${var.environment}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main_ig.id
  }

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Security List for WebRTC Application
resource "oci_core_security_list" "webrtc_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "${var.project_name}-${var.environment}-webrtc-sl"

  # Egress Rules - Allow all outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }

  # Ingress Rules for WebRTC and HTTP/HTTPS
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    description = "HTTP traffic"
    
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    description = "HTTPS traffic"
    
    tcp_options {
      min = 443
      max = 443
    }
  }

  # WebRTC Signaling (typically HTTPS/WSS)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    description = "WebRTC Signaling"
    
    tcp_options {
      min = 8443
      max = 8443
    }
  }

  # STUN/TURN servers (UDP)
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    description = "STUN/TURN UDP traffic"
    
    udp_options {
      min = 3478
      max = 3478
    }
  }

  # TURN server alternative port
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    description = "TURN TCP traffic"
    
    tcp_options {
      min = 3478
      max = 3478
    }
  }

  # RTP/RTCP media traffic (UDP high ports for WebRTC)
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    description = "WebRTC media traffic"
    
    udp_options {
      min = 10000
      max = 60000
    }
  }

  # SSH access (for management)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    description = "SSH access"
    
    tcp_options {
      min = 22
      max = 22
    }
  }

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# Network Security Group for Application-specific rules
resource "oci_core_network_security_group" "app_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "${var.project_name}-${var.environment}-app-nsg"

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}

# NSG Rules for application
resource "oci_core_network_security_group_security_rule" "app_http_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTP traffic to application"

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_https_ingress" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "Allow HTTPS traffic to application"

  tcp_options {
    destination_port_range {
      min = 8443
      max = 8443
    }
  }
}

# Public Subnet
resource "oci_core_subnet" "public_subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.main_vcn.id
  cidr_block          = var.public_subnet_cidr_block
  display_name        = "${var.project_name}-${var.environment}-public-subnet"
  dns_label           = "publicsubnet"
  availability_domain = var.availability_domain
  route_table_id      = oci_core_vcn.main_vcn.default_route_table_id
  security_list_ids   = [oci_core_security_list.webrtc_security_list.id]

  freeform_tags = {
    "Project"     = var.project_name
    "Environment" = var.environment
  }
}