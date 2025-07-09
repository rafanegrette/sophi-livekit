resource "oci_devops_project" "livekit_devops_project" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    name           = "livekit-devops-project"
    description    = "DevOps project for LiveKit agent application"
    
    notification_config {
        topic_id = oci_ons_notification_topic.devops_notifications.id
    }

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
        "OCI_RESOURCE_PRINCIPAL_VERSION" = "2.2"

    }
}

# Create log group for DevOps
resource "oci_logging_log_group" "devops_log_group" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    display_name   = "livekit-devops-log-group"
    description    = "Log group for LiveKit DevOps project"
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}


# Notification topic for DevOps events
resource "oci_ons_notification_topic" "devops_notifications" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    name           = "livekit-devops-notifications"
    description    = "Notifications for LiveKit DevOps events"
}

# Build pipeline
resource "oci_devops_build_pipeline" "livekit_build_pipeline" {
    project_id     = oci_devops_project.livekit_devops_project.id
    display_name   = "livekit-build-pipeline"
    description    = "Build pipeline for LiveKit agent application"
    
    build_pipeline_parameters {
        items {
            name            = "registryUrl"
            default_value   = "${var.region}.ocir.io"
            description     = "Container registry URL"
        }
        items {
            name            = "imageName"
            default_value   = "livekit-agent"
            description     = "Container image name"
        }
        items {
            name            = "tenancyName"
            default_value   = data.oci_identity_tenancy.current_tenancy.name
            description     = "OCI Tenancy name"
        }
    }

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# External connection to GitHub
resource "oci_devops_connection" "github_connection" {
    connection_type = "GITHUB_ACCESS_TOKEN"
    project_id      = oci_devops_project.livekit_devops_project.id
    display_name    = "livekit-github-connection"
    description     = "GitHub connection for LiveKit agent repository"
    
    username =  "rafanegrette"
    access_token = oci_vault_secret.github_pat_secret.id

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# External repository reference
resource "oci_devops_repository" "livekit_external_repo" {
    name               = "livekit-agent-external"
    project_id         = oci_devops_project.livekit_devops_project.id
    repository_type    = "MIRRORED"
    description        = "External GitHub repository for LiveKit agent"
    
    mirror_repository_config {
        connector_id    = oci_devops_connection.github_connection.id
        repository_url  = "https://github.com/rafanegrette/sophi-livekit"
        trigger_schedule {
            schedule_type   = "DEFAULT"
        }
    }

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Build stage (corrected - removed primary_build_source)
resource "oci_devops_build_pipeline_stage" "build_stage" {
    build_pipeline_id = oci_devops_build_pipeline.livekit_build_pipeline.id
    build_pipeline_stage_type = "BUILD"
    display_name = "Build Docker Image"
    description = "Build Docker image from voice-pipeline-agent-python folder"
    
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline.livekit_build_pipeline.id
        }
    }
    
    build_source_collection {
        items {
            connection_type = "DEVOPS_CODE_REPOSITORY"
            repository_id = oci_devops_repository.livekit_external_repo.id
            name = "livekit_source"
            repository_url = "https://github.com/rafanegrette/sophi-livekit.git"
            branch = "main"
        }
    }
    
    build_spec_file = "voice-pipeline-agent-python/build_spec.yaml"
    image = "OL7_X86_64_STANDARD_10"
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}



# Artifact for container image
resource "oci_devops_deploy_artifact" "container_image_artifact" {
    project_id = oci_devops_project.livekit_devops_project.id
    display_name = "livekit-agent-container-image"
    deploy_artifact_type = "DOCKER_IMAGE"
    argument_substitution_mode = "NONE"

    deploy_artifact_source {
        deploy_artifact_source_type = "OCIR"
        image_uri = "${var.region}.ocir.io/${data.oci_artifacts_container_configuration.container_configuration.namespace}/${oci_artifacts_container_repository.livekit_repository.display_name}:$${BUILDRUN_HASH}"
        repository_id = oci_artifacts_container_repository.livekit_repository.id
    }
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
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
            artifact_name = "livekit_agent_image"
        }
    }
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
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
                head_ref = "refs/heads/main"
            }
        }
    }
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Deployment pipeline
resource "oci_devops_deploy_pipeline" "livekit_deploy_pipeline" {
    project_id     = oci_devops_project.livekit_devops_project.id
    display_name   = "livekit-deploy-pipeline"
    description    = "Deployment pipeline for LiveKit agent to OKE"

    deploy_pipeline_parameters {
        items {
            name            = "NAMESPACE"
            default_value   = "livekit"
            description     = "Kubernetes namespace"
        }
        items {
            name            = "REPLICAS"
            default_value   = "1"
            description     = "Number of replicas"
        }
    }

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# OKE Environment for deployment
resource "oci_devops_deploy_environment" "oke_environment" {
    deploy_environment_type = "OKE_CLUSTER"
    project_id              = oci_devops_project.livekit_devops_project.id
    display_name            = "livekit-oke-environment"
    description             = "OKE cluster environment for LiveKit deployment"
    
    cluster_id = oci_containerengine_cluster.oke-cluster.id

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}


resource "oci_devops_deploy_artifact" "kubernetes_manifest_artifact" {
    project_id = oci_devops_project.livekit_devops_project.id
    display_name = "livekit-kubernetes-manifests"
    deploy_artifact_type = "KUBERNETES_MANIFEST"
    argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"

    deploy_artifact_source {
        deploy_artifact_source_type = "GENERIC_ARTIFACT"
        repository_id = oci_devops_repository.livekit_external_repo.id
        deploy_artifact_path = "voice-pipeline-agent-python/k8s-manifests"
        deploy_artifact_version = "latest"
    }
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Deploy stage using Helm charts
resource "oci_devops_deploy_stage" "kubernetes_deploy_stage" {
    deploy_pipeline_id = oci_devops_deploy_pipeline.livekit_deploy_pipeline.id
    deploy_stage_type = "OKE_DEPLOYMENT"
    display_name = "Deploy to OKE using Kubernetes Manifests"
    description = "Deploy LiveKit agent to OKE cluster using Kubernetes manifests"
    
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
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
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

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Create log for DevOps builds
resource "oci_logging_log" "devops_build_log" {
    display_name       = "livekit-devops-build-log"
    log_group_id       = oci_logging_log_group.devops_log_group.id
    log_type           = "SERVICE"
    
    configuration {
        source {
            category    = "all"
            resource    = oci_devops_project.livekit_devops_project.id
            service     = "devops"
            source_type = "OCISERVICE"
        }
        
        compartment_id = oci_identity_compartment.tf-compartment.id
    }
    
    is_enabled         = true
    retention_duration = 30
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}