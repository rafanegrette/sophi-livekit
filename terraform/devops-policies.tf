resource "oci_identity_dynamic_group" "devops_services" {
    compartment_id = var.tenancy_ocid
    description    = "Dynamic group for DevOps services"
    name           = "livekit-devops-services"

    matching_rule = "ANY {resource.type='devopsbuildpipeline', resource.type='devopsdeploypipeline', resource.compartment.id='${oci_identity_compartment.tf-compartment.id}'}"
}

resource "oci_identity_policy" "devops_policy" {
    compartment_id = var.tenancy_ocid
    description    = "Policy for DevOps services with vault and logging access"
    name           = "livekit-devops-policy"
    
    statements = [
        "allow dynamic-group livekit-devops-services to manage all-resources in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-devops-services to read secret-family in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-devops-services to manage repos in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-devops-services to manage devops-family in compartment ${oci_identity_compartment.tf-compartment.name}",
        "allow dynamic-group livekit-devops-services to use log-content in compartment ${oci_identity_compartment.tf-compartment.name}"
    ]
}