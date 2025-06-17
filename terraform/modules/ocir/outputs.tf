output "repository_id" {
  description = "ID of the container repository"
  value       = oci_artifacts_container_repository.app_repository.id
}

output "repository_url" {
  description = "URL of the container repository"
  value       = "${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.app_repository.display_name}"
}

output "repository_namespace" {
  description = "Namespace of the container repository"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "repository_display_name" {
  description = "Display name of the container repository"
  value       = oci_artifacts_container_repository.app_repository.display_name
}

output "dynamic_group_id" {
  description = "ID of the dynamic group for container instances"
  value       = oci_identity_dynamic_group.container_instance_group.id
}

output "policy_id" {
  description = "ID of the OCIR policy"
  value       = oci_identity_policy.ocir_policy.id
}

output "developer_group_id" {
  description = "ID of the developer group"
  value       = var.create_developer_group ? oci_identity_group.developers[0].id : null
}

output "auth_token" {
  description = "Auth token for OCIR access (sensitive)"
  value       = var.create_auth_token ? oci_identity_auth_token.ocir_token[0].token : null
  sensitive   = true
}
