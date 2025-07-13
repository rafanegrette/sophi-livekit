# VCN outputs
output "vcn_id" {
  description = "OCID of the VCN"
  value       = module.vcn.vcn_id
}

output "vcn_name" {
  description = "Name of the VCN"
  value       = var.vcn_name
}

# Gateway outputs
output "internet_gateway_id" {
  description = "OCID of the internet gateway"
  value       = module.vcn.internet_gateway_id
}

output "nat_gateway_id" {
  description = "OCID of the NAT gateway"
  value       = module.vcn.nat_gateway_id
}

output "service_gateway_id" {
  description = "OCID of the service gateway"
  value       = module.vcn.service_gateway_id
}

# Route table outputs
output "ig_route_id" {
  description = "OCID of the internet gateway route table"
  value       = module.vcn.ig_route_id
}

output "nat_route_id" {
  description = "OCID of the NAT gateway route table"
  value       = module.vcn.nat_route_id
}

# Security List outputs
output "public_security_list_id" {
  description = "OCID of the public security list"
  value       = oci_core_security_list.public_security_list.id
}

output "public_security_list_name" {
  description = "Name of the public security list"
  value       = oci_core_security_list.public_security_list.display_name
}

output "private_security_list_id" {
  description = "OCID of the private security list"
  value       = oci_core_security_list.private_security_list.id
}

output "private_security_list_name" {
  description = "Name of the private security list"
  value       = oci_core_security_list.private_security_list.display_name
}

# Subnet outputs
output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public_subnet.id
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = oci_core_subnet.public_subnet.display_name
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private_subnet.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = oci_core_subnet.private_subnet.display_name
}