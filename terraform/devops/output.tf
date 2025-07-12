output "devops_project_id" {
  description = "The OCID of the DevOps project"
  value       = oci_devops_project.livekit_devops_project.id
}

output "build_pipeline_id" {
  description = "The OCID of the build pipeline"
  value       = oci_devops_build_pipeline.livekit_build_pipeline.id
}

output "deploy_pipeline_id" {
  description = "The OCID of the deploy pipeline"
  value       = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
}

output "github_connection_id" {
  description = "The OCID of the GitHub connection"
  value       = oci_devops_connection.github_connection.id
}

output "external_repository_id" {
  description = "The OCID of the external repository"
  value       = oci_devops_repository.livekit_external_repo.id
}

output "oke_environment_id" {
  description = "The OCID of the OKE deployment environment"
  value       = oci_devops_deploy_environment.oke_environment.id
}

output "devops_dynamic_group_id" {
  description = "The OCID of the DevOps dynamic group"
  value       = oci_identity_dynamic_group.devops_services.id
}

output "devops_policy_id" {
  description = "The OCID of the DevOps policy"
  value       = oci_identity_policy.devops_policy.id
}

output "log_group_id" {
  description = "The OCID of the DevOps log group"
  value       = oci_logging_log_group.devops_log_group.id
}