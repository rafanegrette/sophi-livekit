output "vcn_id" {
  description = "ID of the VCN"
  value       = oci_core_vcn.main_vcn.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = oci_core_subnet.public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = oci_core_internet_gateway.main_ig.id
}

output "security_list_id" {
  description = "ID of the security list"
  value       = oci_core_security_list.webrtc_security_list.id
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = oci_core_network_security_group.app_nsg.id
}

output "vcn_cidr_block" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.main_vcn.cidr_blocks[0]
}
