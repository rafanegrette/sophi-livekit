locals {
  # Map full region names to OCIR region codes
  region_map = {
    "us-phoenix-1"   = "phx"
    "us-ashburn-1"   = "iad"
    "uk-london-1"    = "lhr"
    "eu-frankfurt-1" = "fra"
    "ap-tokyo-1"     = "nrt"
    "ap-seoul-1"     = "icn"
    "ap-sydney-1"    = "syd"
    "ap-mumbai-1"    = "bom"
    "ca-toronto-1"   = "yyz"
    "sa-saopaulo-1"  = "gru"
    # Add other regions as needed
  }
  ocir_region = local.region_map[var.region]
  container_registry_url = "${local.ocir_region}.ocir.io/${var.build_pipeline_params.tenancy_namespace}/${var.build_pipeline_params.image_name}"
}

resource "oci_devops_project" "livekit_devops_project" {
    compartment_id = var.compartment_id
    name           = "livekit-devops-project"
    description    = "DevOps project for LiveKit agent application"
    
    notification_config {
        topic_id = oci_ons_notification_topic.devops_notifications.id
    }

    freeform_tags = var.freeform_tags
}

# Create log group for DevOps
resource "oci_logging_log_group" "devops_log_group" {
    compartment_id = var.compartment_id
    display_name   = "${var.project_name}-log-group"
    description    = "Log group for LiveKit DevOps project"
    
    freeform_tags = var.freeform_tags
}


# Notification topic for DevOps events
resource "oci_ons_notification_topic" "devops_notifications" {
    compartment_id = var.compartment_id
    name           = "${var.project_name}-notifications"
    description    = "Notifications for LiveKit DevOps events"
}

# Build pipeline
resource "oci_devops_build_pipeline" "livekit_build_pipeline" {
    project_id     = oci_devops_project.livekit_devops_project.id
    display_name   = "${var.project_name}-build-pipeline"
    description    = "Build pipeline for ${var.project_name} application"
    
    build_pipeline_parameters {
        items {
            name            = "registryUrl"
            default_value   = var.build_pipeline_params.registry_url
            description     = "Container registry URL"
        }
        items {
            name            = "imageName"
            default_value   = var.build_pipeline_params.image_name
            description     = "Container image name"
        }
        items {
            name            = "tenancyName"
            default_value   = var.build_pipeline_params.tenancy_name
            description     = "OCI Tenancy name"
        }
        items {
            name            = "userName"
            default_value   = var.build_pipeline_params.user_name
            description     = "Current OCI user name"
        }
        items {
            name            = "tenancyNamespace"
            default_value   = var.build_pipeline_params.tenancy_namespace
            description     = "OCI Tenancy namespace for Object Storage and Container Registry"
        }
    }

    freeform_tags = var.freeform_tags
}

# External connection to GitHub
resource "oci_devops_connection" "github_connection" {
    connection_type = "GITHUB_ACCESS_TOKEN"
    project_id      = oci_devops_project.livekit_devops_project.id
    display_name    = "${var.project_name}-github-connection"
    description     = "GitHub connection for ${var.project_name} agent repository"
    
    username =  var.github_config.username
    access_token = var.github_config.access_token_secret_id

    freeform_tags = var.freeform_tags
}

# External repository reference
resource "oci_devops_repository" "livekit_external_repo" {
    name               = "${var.project_name}-external"
    project_id         = oci_devops_project.livekit_devops_project.id
    repository_type    = "MIRRORED"
    description        = "External GitHub repository for ${var.project_name}"
    
    mirror_repository_config {
        connector_id    = oci_devops_connection.github_connection.id
        repository_url  = var.github_config.repository_url
        trigger_schedule {
            schedule_type   = "DEFAULT"
        }
    }

    freeform_tags = var.freeform_tags
}

# Build stage (corrected - removed primary_build_source)
resource "oci_devops_build_pipeline_stage" "build_stage" {
    build_pipeline_id = oci_devops_build_pipeline.livekit_build_pipeline.id
    build_pipeline_stage_type = "BUILD"
    display_name = "Build Docker Image"
    description = "Build Docker image from ${var.build_config.source_folder} folder"
    
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline.livekit_build_pipeline.id
        }
    }
    
    build_source_collection {
        items {
            connection_type = "DEVOPS_CODE_REPOSITORY"
            repository_id = oci_devops_repository.livekit_external_repo.id
            name = "${var.project_name}_source"
            repository_url = var.github_config.repository_url
            branch = var.github_config.branch
        }
    }

    stage_execution_timeout_in_seconds = var.build_config.timeout_seconds
    
    build_spec_file = var.build_config.build_spec_file

    image = var.build_config.image
    
    freeform_tags = var.freeform_tags
}



# Artifact for container image
resource "oci_devops_deploy_artifact" "container_image_artifact" {
    project_id = oci_devops_project.livekit_devops_project.id
    display_name = "${var.project_name}-container-image"
    deploy_artifact_type = "DOCKER_IMAGE"
    argument_substitution_mode = "NONE"

    deploy_artifact_source {
        deploy_artifact_source_type = "OCIR"
        image_uri = var.container_registry.image_uri
        repository_id = var.container_registry.repository_id
    }
    
    freeform_tags = var.freeform_tags
}

# Deliver artifacts stage
resource "oci_devops_build_pipeline_stage" "deliver_artifacts_stage" {
    build_pipeline_id = oci_devops_build_pipeline.livekit_build_pipeline.id
    build_pipeline_stage_type = "DELIVER_ARTIFACT"
    display_name = "Deliver Container Image"
    description = "Deliver built container image to Container Registry"
    
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline_stage.build_stage.id
        }
    }
    
    deliver_artifact_collection {
        items {
            artifact_id = oci_devops_deploy_artifact.container_image_artifact.id
            artifact_name = "${var.project_name}_agent_image"
        }
    }
    
    freeform_tags = var.freeform_tags
}

# Trigger for automatic pipeline execution on push
resource "oci_devops_trigger" "github_push_trigger" {
    project_id = oci_devops_project.livekit_devops_project.id
    trigger_source = "DEVOPS_CODE_REPOSITORY"
    display_name = "GitHub Push Trigger"
    description = "Trigger build pipeline on push to GitHub repository"
    
    repository_id = oci_devops_repository.livekit_external_repo.id
    
    actions {
        type = "TRIGGER_BUILD_PIPELINE"
        build_pipeline_id = oci_devops_build_pipeline.livekit_build_pipeline.id
        filter {
            trigger_source = "DEVOPS_CODE_REPOSITORY"
            events = ["PUSH"]
            include {
                head_ref = "refs/heads/${var.github_config.branch}"
            }
        }
    }
    
    freeform_tags = var.freeform_tags
}

# Deployment pipeline
resource "oci_devops_deploy_pipeline" "livekit_deploy_pipeline" {
    project_id     = oci_devops_project.livekit_devops_project.id
    display_name   = "${var.project_name}-deploy-pipeline"
    description    = "Deployment pipeline for ${var.project_name} agent to OKE"

    deploy_pipeline_parameters {
        items {
            name            = "NAMESPACE"
            default_value   = var.deploy_config.namespace
            description     = "Kubernetes namespace"
        }
        items {
            name            = "REPLICAS"
            default_value   = var.deploy_config.replicas
            description     = "Number of replicas"
        }
        # Add environment variables from app_secrets
        items {
            name            = "LIVEKIT_KEY"
            default_value   = var.app_secrets.livekit_key
            description     = "LiveKit API Key"
        }
        items {
            name            = "LIVEKIT_SECRET"
            default_value   = var.app_secrets.livekit_secret
            description     = "LiveKit API Secret"
        }
        items {
            name            = "LIVEKIT_URL"
            default_value   = var.app_secrets.livekit_url
            description     = "LiveKit WebSocket URL"
        }
        items {
            name            = "CARTESIA_API_KEY"
            default_value   = var.app_secrets.cartesia_api_key
            description     = "Cartesia API Key"
        }
        items {
            name            = "DEEPGRAM_API_KEY"
            default_value   = var.app_secrets.deepgram_api_key
            description     = "Deepgram API Key"
        }
        items {
            name            = "OPENAI_API_KEY"
            default_value   = var.app_secrets.openai_api_key
            description     = "OpenAI API Key"
        }
        items {
            name            = "DEEPSEEK_API_KEY"
            default_value   = var.app_secrets.deepseek_api_key
            description     = "Deepseek API Key"
        }
        items {
            name            = "CONTAINER_REGISTRY_URL"
            default_value   = local.container_registry_url
            description     = "Container registry URL"
        }
    }

    freeform_tags = var.freeform_tags
}

# OKE Environment for deployment
resource "oci_devops_deploy_environment" "oke_environment" {
    deploy_environment_type = "OKE_CLUSTER"
    project_id              = oci_devops_project.livekit_devops_project.id
    display_name            = "${var.project_name}-oke-environment"
    description             = "OKE cluster environment for ${var.project_name} deployment"
    
    cluster_id = var.oke_cluster_id

    freeform_tags = var.freeform_tags
}


resource "oci_devops_deploy_artifact" "kubernetes_manifest_artifact" {
    project_id = oci_devops_project.livekit_devops_project.id
    display_name = "livekit-kubernetes-manifests"
    deploy_artifact_type = "KUBERNETES_MANIFEST"
    argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"

    deploy_artifact_source {
        deploy_artifact_source_type = "GENERIC_ARTIFACT"
        repository_id = oci_devops_repository.livekit_external_repo.id
        deploy_artifact_path = var.deploy_config.manifest_path
        deploy_artifact_version = "latest"
    }
    
    freeform_tags = var.freeform_tags
}

# Deploy stage using Helm charts
resource "oci_devops_deploy_stage" "kubernetes_deploy_stage" {
    deploy_pipeline_id = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
    deploy_stage_type = "OKE_DEPLOYMENT"
    display_name = "Deploy to OKE using Kubernetes Manifests"
    description = "Deploy ${var.project_name} agent to OKE cluster using Kubernetes manifests"
    
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
        }
    }
    
    # Configuration for OKE Kubernetes manifest deployment
    oke_cluster_deploy_environment_id = oci_devops_deploy_environment.oke_environment.id
    kubernetes_manifest_deploy_artifact_ids = [oci_devops_deploy_artifact.kubernetes_manifest_artifact.id]
    
    namespace = "$${NAMESPACE}"
    
    # Rollback policy
    rollback_policy {
        policy_type = "AUTOMATED_STAGE_ROLLBACK_POLICY"
    }
    
    freeform_tags = var.freeform_tags
}

# Connect build pipeline to deploy pipeline
resource "oci_devops_build_pipeline_stage" "trigger_deployment_stage" {
    build_pipeline_id = oci_devops_build_pipeline.livekit_build_pipeline.id
    build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"
    display_name = "Trigger Deployment"
    description = "Trigger deployment pipeline after successful build"
    
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline_stage.deliver_artifacts_stage.id
        }
    }
    
    # Direct configuration for triggering deployment pipeline
    deploy_pipeline_id = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
    is_pass_all_parameters_enabled = true

    freeform_tags = var.freeform_tags
}

# Create log for DevOps builds
resource "oci_logging_log" "devops_build_log" {
    display_name       = "${var.project_name}-build-log"
    log_group_id       = oci_logging_log_group.devops_log_group.id
    log_type           = "SERVICE"
    
    configuration {
        source {
            category    = "all"
            resource    = oci_devops_project.livekit_devops_project.id
            service     = "devops"
            source_type = "OCISERVICE"
        }
        
        compartment_id = var.compartment_id
    }
    
    is_enabled         = true
    retention_duration = var.log_retention_days
    
    freeform_tags = var.freeform_tags
}

