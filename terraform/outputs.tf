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




# Data source to get current region


output "artifact_registry_repository_name" {
    description = "Name of the artifact registry repository"
    value       = oci_artifacts_container_repository.livekit_repository.display_name
}

output "artifact_registry_repository_ocid" {
    description = "OCID of the artifact registry repository"
    value       = oci_artifacts_container_repository.livekit_repository.id
}

output "artifact_registry_namespace" {
    description = "Artifact registry namespace"
    value       = data.oci_artifacts_container_configuration.container_configuration.namespace
}

output "container_registry_url" {
    description = "Container registry URL for pushing/pulling images"
    value       = "${var.region}.ocir.io/${data.oci_artifacts_container_configuration.container_configuration.namespace}/${oci_artifacts_container_repository.livekit_repository.display_name}"
    sensitive   = true
}

output "container_registry_path" {
    description = "Container registry path (without region prefix)"
    value       = "${data.oci_artifacts_container_configuration.container_configuration.namespace}/${oci_artifacts_container_repository.livekit_repository.display_name}"
}

output "dynamic_group_instances_ocid" {
    description = "OCID of the dynamic group for instances"
    value       = oci_identity_dynamic_group.livekit_instances.id
}

output "dynamic_group_oke_cluster_ocid" {
    description = "OCID of the dynamic group for OKE cluster"
    value       = oci_identity_dynamic_group.livekit_oke_cluster.id
}


# Build Pipeline Outputs
output "build_pipeline_name" {
    description = "Name of the build pipeline"
    value       = oci_devops_build_pipeline.livekit_build_pipeline.display_name
}

output "build_pipeline_ocid" {
    description = "OCID of the build pipeline"
    value       = oci_devops_build_pipeline.livekit_build_pipeline.id
}

# Deploy Pipeline Outputs
output "deploy_pipeline_name" {
    description = "Name of the deploy pipeline"
    value       = oci_devops_deploy_pipeline.livekit_deploy_pipeline.display_name
}

output "deploy_pipeline_ocid" {
    description = "OCID of the deploy pipeline"
    value       = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
}


# OKE Environment Outputs
output "oke_environment_name" {
    description = "Name of the OKE deployment environment"
    value       = oci_devops_deploy_environment.oke_environment.display_name
}

output "oke_environment_ocid" {
    description = "OCID of the OKE deployment environment"
    value       = oci_devops_deploy_environment.oke_environment.id
}

# Notification Topic Outputs
output "devops_notification_topic_name" {
    description = "Name of the DevOps notification topic"
    value       = oci_ons_notification_topic.devops_notifications.name
}

output "devops_notification_topic_ocid" {
    description = "OCID of the DevOps notification topic"
    value       = oci_ons_notification_topic.devops_notifications.id
}

# Dynamic Group Output
output "devops_dynamic_group_ocid" {
    description = "OCID of the DevOps services dynamic group"
    value       = oci_identity_dynamic_group.devops_services.id
}


output "github_connection_name" {
    description = "Name of the GitHub connection"
    value       = oci_devops_connection.github_connection.display_name
}

output "github_connection_ocid" {
    description = "OCID of the GitHub connection"
    value       = oci_devops_connection.github_connection.id
}

# External Repository Outputs
output "external_repository_name" {
    description = "Name of the external GitHub repository"
    value       = oci_devops_repository.livekit_external_repo.name
}

output "external_repository_ocid" {
    description = "OCID of the external GitHub repository"
    value       = oci_devops_repository.livekit_external_repo.id
}