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