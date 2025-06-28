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

## k8s cluster

output "cluster-name" {
  value = oci_containerengine_cluster.oke-cluster.name
}

output "cluster-OCID" {
  value = oci_containerengine_cluster.oke-cluster.id
}

output "cluster-kubernetes-version" {
  value = oci_containerengine_cluster.oke-cluster.kubernetes_version
}

output "cluster-state" {
  value = oci_containerengine_cluster.oke-cluster.state
}

output "node-pool-name" {
  value = oci_containerengine_node_pool.oke-node-pool.name
}

output "node-pool-OCID" {
  value = oci_containerengine_node_pool.oke-node-pool.id
}

output "node-pool-kubernetes-version" {
  value = oci_containerengine_node_pool.oke-node-pool.node_config_details[0].size
}

output "node-shape" {
  value = oci_containerengine_node_pool.oke-node-pool.node_shape
}