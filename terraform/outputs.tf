output "all-availability-domains-in-your-tenancy" {
    value = data.oci_identity_availability_domains.ads.availability_domains
}

output "compartment-name" {
    value = oci_identity_compartment.tf-compartment.name
}

output "compartment-OCID" {
    value = oci_identity_compartment.tf-compartment.id
}

output "name-of-first-availability-domain" {
    value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "vcn_id" {
    description = "OCID of the VCN created"
    value = module.vcn.vcn_id
}

output "id-for-route-table-that-includes-the-internet-gateway" {
  description = "OCID of the internet-route table. This route table has an internet gateway to be used for public subnets"
  value = module.vcn.ig_route_id
}
output "nat-gateway-id" {
  description = "OCID for NAT gateway"
  value = module.vcn.nat_gateway_id
}
output "id-for-for-route-table-that-includes-the-nat-gateway" {
  description = "OCID of the nat-route table - This route table has a nat gateway to be used for private subnets. This route table also has a service gateway."
  value = module.vcn.nat_route_id
}

output "public-subnet-name" {
  value = oci_core_subnet.vcn-public-subnet.display_name
}

output "public-subnet-OCID" {
  value = oci_core_subnet.vcn-public-subnet.id
}

output "public-security-list-name" {
  value  = oci_core_security_list.public-security-list.display_name  
}

output "public-security-list-OCID" {
  value = oci_core_security_list.public-security-list.id
}

output "private-security-list-name" {
  value = oci_core_security_list.private-security-list.display_name
}
output "private-security-list-OCID" {
  value = oci_core_security_list.private-security-list.id
}

# OKE Cluster outputs (via module)
output "cluster-name" {
  value = module.oke_cluster.cluster_name
}

output "cluster-OCID" {
  value = module.oke_cluster.cluster_id
}

output "artifact_registry_repository_name" {
    description = "Name of the artifact registry repository"
    value       = module.oke_cluster.container_repository_name
}

output "container_registry_url" {
    description = "Container registry URL for pushing/pulling images"
    value       = "${var.region}.ocir.io/${module.oke_cluster.container_registry_url}/${module.oke_cluster.container_repository_name}"
    sensitive   = true
}

output "dynamic_group_instances_ocid" {
    description = "OCID of the dynamic group for instances"
    value       = oci_identity_dynamic_group.livekit_instances.id
}

output "dynamic_group_oke_cluster_ocid" {
    description = "OCID of the dynamic group for OKE cluster"
    value       = oci_identity_dynamic_group.livekit_oke_cluster.id
}