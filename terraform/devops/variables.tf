variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "compartment_name" {
  description = "The name of the compartment"
  type        = string
}

variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "project_name" {
  description = "Name of the DevOps project"
  type        = string
  default     = "livekit"
}

variable "project_description" {
  description = "Description of the DevOps project"
  type        = string
  default     = "DevOps project for LiveKit agent application"
}

variable "freeform_tags" {
  description = "Freeform tags for resources"
  type        = map(string)
  default     = {
    "Environment" = "development"
    "Project"     = "livekit"
    "OCI_RESOURCE_PRINCIPAL_VERSION" = "2.2"
  }
}

variable "build_pipeline_params" {
  description = "Build pipeline parameters"
  type = object({
    registry_url      = string
    image_name        = string
    tenancy_name      = string
    user_name         = string
    tenancy_namespace = string
  })
}

variable "github_config" {
  description = "GitHub configuration"
  type = object({
    username              = string
    access_token_secret_id = string
    repository_url        = string
    branch               = string
  })
}

variable "build_config" {
  description = "Build configuration"
  type = object({
    source_folder    = string
    timeout_seconds  = number
    build_spec_file  = string
    image           = string
  })
  default = {
    source_folder   = "voice-pipeline-agent-python"
    timeout_seconds = 3600
    build_spec_file = "voice-pipeline-agent-python/build_spec.yaml"
    image          = "OL7_X86_64_STANDARD_10"
  }
}

variable "container_registry" {
  description = "Container registry configuration"
  type = object({
    image_uri     = string
    repository_id = string
  })
}

variable "deploy_config" {
  description = "Deployment configuration"
  type = object({
    namespace     = string
    replicas      = string
    manifest_path = string
  })
  default = {
    namespace     = "livekit"
    replicas      = "1"
    manifest_path = "voice-pipeline-agent-python/k8s-manifests"
  }
}

variable "oke_cluster_id" {
  description = "OKE cluster ID for deployment"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 90
}