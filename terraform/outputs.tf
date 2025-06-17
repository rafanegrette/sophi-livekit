output "compartment_id" {
  description = "ID of the created compartment"
  value       = oci_identity_compartment.main_compartment.id
}

output "vcn_id" {
  description = "ID of the VCN"
  value       = module.networking.vcn_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = module.networking.internet_gateway_id
}

output "ocir_repository_url" {
  description = "URL of the container repository"
  value       = module.ocir.repository_url
}

output "ocir_repository_id" {
  description = "ID of the container repository"
  value       = module.ocir.repository_id
}

output "ocir_namespace" {
  description = "OCIR namespace"
  value       = module.ocir.repository_namespace
}

output "ocir_dynamic_group_id" {
  description = "ID of the dynamic group for container access"
  value       = module.ocir.dynamic_group_id
}
