# Cluster outputs
output "cluster_id" {
  description = "The OCID of the OKE cluster"
  value       = oci_containerengine_cluster.oke-cluster.id
}

output "cluster_name" {
  description = "The name of the OKE cluster"
  value       = oci_containerengine_cluster.oke-cluster.name
}

output "cluster_kubernetes_version" {
  description = "The Kubernetes version of the cluster"
  value       = oci_containerengine_cluster.oke-cluster.kubernetes_version
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = oci_containerengine_cluster.oke-cluster.endpoints
}

# Node Pool outputs
output "node_pool_id" {
  description = "The OCID of the node pool"
  value       = oci_containerengine_node_pool.oke-node-pool.id
}

output "node_pool_name" {
  description = "The name of the node pool"
  value       = oci_containerengine_node_pool.oke-node-pool.name
}

output "node_pool_kubernetes_version" {
  description = "The Kubernetes version of the node pool"
  value       = oci_containerengine_node_pool.oke-node-pool.kubernetes_version
}

# Artifact Registry outputs
output "container_repository_id" {
  description = "The OCID of the container repository"
  value       = oci_artifacts_container_repository.livekit_repository.id
}

output "container_repository_name" {
  description = "The name of the container repository"
  value       = oci_artifacts_container_repository.livekit_repository.display_name
}

output "container_registry_url" {
  description = "The container registry URL"
  value       = data.oci_artifacts_container_configuration.container_configuration.namespace
}