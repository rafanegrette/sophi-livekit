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
            name            = "REGISTRY_URL"
            default_value   = "${var.region}.ocir.io"
            description     = "Container registry URL"
        }
        items {
            name            = "IMAGE_NAME"
            default_value   = "livekit-agent"
            description     = "Container image name"
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

# Artifact repository for build artifacts
resource "oci_devops_repository" "livekit_code_repo" {
    name            = "livekit-agent-code"
    project_id      = oci_devops_project.livekit_devops_project.id
    repository_type = "HOSTED"
    description     = "Source code repository for LiveKit agent"

    default_branch = "main"

    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}