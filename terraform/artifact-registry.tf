resource "oci_artifacts_container_repository" "livekit_repository" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    display_name   = "livekit-agent"
    is_immutable   = false
    is_public      = false
    
    readme {
        content = "Container repository for LiveKit agent application"
        format  = "text/plain"
    }
}

# Data source to get the container registry
data "oci_artifacts_container_configuration" "container_configuration" {
    compartment_id = oci_identity_compartment.tf-compartment.id
}