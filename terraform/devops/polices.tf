resource "oci_identity_dynamic_group" "devops_services" {
    compartment_id = var.tenancy_ocid
    description    = "Dynamic group for DevOps services"
    name           = "${var.project_name}-devops-services"

    matching_rule = "ALL {resource.compartment.id = '${var.compartment_id}', ANY {resource.type = 'devopsdeploypipeline', resource.type = 'devopsbuildpipeline', resource.type = 'devopsrepository', resource.type = 'devopsconnection', resource.type = 'devopstrigger'}}"
}

resource "oci_identity_policy" "devops_policy" {
    compartment_id = var.tenancy_ocid
    description    = "Policy for DevOps services with vault and logging access"
    name           = "livekit-devops-policy"
    
    statements = [
        "allow dynamic-group ${var.project_name}-devops-services to manage all-resources in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to read secret-family in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to manage repos in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to manage devops-family in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to use log-content in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to read generic-artifacts in compartment ${var.compartment_name}",
        "allow dynamic-group ${var.project_name}-devops-services to read devops-repository in compartment ${var.compartment_name}",
        "Allow dynamic-group ${var.project_name}-devops-services to read secret-bundles in compartment ${var.compartment_name}",
        "Allow dynamic-group ${var.project_name}-devops-services to use vaults in compartment ${var.compartment_name}"
    ]
}