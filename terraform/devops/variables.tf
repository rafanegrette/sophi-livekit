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
  description = "Build configuration for the DevOps pipeline"
  type = object({
    source_folder    = string
    timeout_seconds  = number
    build_spec_file  = string
    # ⬇️ Add these new attributes for the compute shape
    compute_shape    = string
    ocpu             = number
    memory_in_gbs    = number
    image           = string
  })
  default = {
    source_folder   = "voice-pipeline-agent-python"
    timeout_seconds = 3600
    build_spec_file = "voice-pipeline-agent-python/build_spec.yaml"
    # ⬇️ Set the default shape to a common ARM shape
    compute_shape   = "VM.Standard2.1"
    ocpu            = 4
    memory_in_gbs   = 12
    image = "OL7_X86_64_STANDARD_10"
  }
}




variable "deploy_config" {
  description = "Deployment configuration"
  type = object({
    namespace     = string
    replicas      = string
  })
  default = {
    namespace     = "livekit"
    replicas      = "1"
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

variable "app_secrets" {
  description = "Application secrets for deployment"
  type = object({
    livekit_key        = string
    livekit_secret     = string
    livekit_url        = string
    cartesia_api_key   = string
    deepgram_api_key   = string
    openai_api_key     = string
    deepseek_api_key   = string
    milvus_host        = string
    milvus_token       = string
  })
  sensitive = true
}

variable "region" {
  description = "The OCI region where resources will be created"
  type        = string
  # no default value, asking user to explicitly set this variable's value
}