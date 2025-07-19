# General variables
variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

# Cluster variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.33.1"
}

variable "cluster_name" {
  description = "Name of the OKE cluster"
  type        = string
  default     = "livekit-agent-cluster"
}

variable "vcn_id" {
  description = "VCN ID where the cluster will be created"
  type        = string
}

variable "is_kubernetes_dashboard_enabled" {
  description = "Enable Kubernetes Dashboard"
  type        = bool
  default     = false
}

variable "is_tiller_enabled" {
  description = "Enable Tiller"
  type        = bool
  default     = false
}

variable "pods_cidr" {
  description = "CIDR block for pods"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "CIDR block for services"
  type        = string
  default     = "10.96.0.0/16"
}

variable "service_lb_subnet_ids" {
  description = "List of subnet IDs for service load balancers"
  type        = list(string)
}

# Node Pool variables
variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
  default     = "pool1"
}

variable "availability_domain" {
  description = "Availability domain for node placement"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for node placement"
  type        = string
}

variable "node_pool_size" {
  description = "Number of nodes in the pool"
  type        = number
  default     = 1
}

variable "node_shape" {
  description = "Shape of the nodes"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_memory_in_gbs" {
  description = "Memory in GBs for each node"
  type        = number
  default     = 6
}

variable "node_ocpus" {
  description = "Number of OCPUs for each node"
  type        = number
  default     = 1
}

variable "node_image_id" {
  description = "Image ID for the nodes"
  type        = string
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GBs"
  type        = number
  default     = 50
}

variable "node_label_key" {
  description = "Key for initial node label"
  type        = string
  default     = "name"
}

variable "node_label_value" {
  description = "Value for initial node label"
  type        = string
  default     = "livekit-cluster"
}

# Artifact Registry variables
variable "repository_name" {
  description = "Name of the container repository"
  type        = string
  default     = "livekit-agent"
}

variable "repository_is_immutable" {
  description = "Whether the repository is immutable"
  type        = bool
  default     = false
}

variable "repository_is_public" {
  description = "Whether the repository is public"
  type        = bool
  default     = false
}

variable "repository_readme_content" {
  description = "Content of the repository readme"
  type        = string
  default     = "Container repository for LiveKit agent application"
}

variable "repository_readme_format" {
  description = "Format of the repository readme"
  type        = string
  default     = "text/plain"
}

variable "app_namespace" {
  description = "Name of the Kubernetes namespace"
  type        = string
  default     = "livekit"
}


variable "app_config" {
  description = "Non-sensitive application configuration"
  type = object({
    app_env   = string
    log_level = string
    app_port  = string
  })
  default = {
    app_env   = "production"
    log_level = "info"
    app_port  = "8080"
  }
}

variable "app_config_name" {
  description = "Name of the Kubernetes config map"
  type        = string
  default     = "app-config"
}

variable "app_secrets_name" {
  description = "Name of the Kubernetes secret"
  type        = string
  default     = "app-secrets"
}

variable "region" {
  description = "The OCI region"
  type        = string
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/oke_cluester_key.pub"
}