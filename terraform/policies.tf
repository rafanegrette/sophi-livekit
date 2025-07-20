resource "oci_identity_dynamic_group" "livekit_instances" {
    compartment_id = var.tenancy_ocid
    description    = "Dynamic group for LiveKit instances"
    name           = "livekit-instances"
    
    matching_rule = "ALL {instance.compartment.id = '${oci_identity_compartment.tf-compartment.id}'}"
}

resource "oci_identity_dynamic_group" "livekit_oke_cluster" {
    compartment_id = var.tenancy_ocid
    description    = "Dynamic group for LiveKit OKE cluster"
    name           = "livekit-oke-cluster"
    
    matching_rule = "ALL {resource.type='cluster', resource.compartment.id='${oci_identity_compartment.tf-compartment.id}'}"
}

resource "oci_identity_policy" "instances_artifact_policy" {
    compartment_id = var.tenancy_ocid
    description    = "Policy for compute instances to access artifact registry"
    name           = "livekit-instances-artifact-policy"

    statements = [
        "allow dynamic-group livekit-instances to manage repos in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-instances to read repos in tenancy"
    ]
}

resource "oci_identity_policy" "oke_artifact_policy" {
    compartment_id = var.tenancy_ocid
    description    = "Policy for OKE cluster to access artifact registry"
    name           = "livekit-oke-artifact-policy"
    
    statements = [
        "allow dynamic-group livekit-oke-cluster to manage repos in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-oke-cluster to read repos in tenancy",
        "allow dynamic-group livekit-oke-cluster to read repos in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-oke-cluster to read objectstorage-namespaces in tenancy",
        "allow dynamic-group livekit-oke-cluster to use repos in compartment ${oci_identity_compartment.tf-compartment.name}"
    ]
}
