resource "oci_containerengine_cluster" "oke-cluster" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    kubernetes_version = "v1.33.1"
    name = "livekit-agent-cluster"
    vcn_id = module.vcn.vcn_id

    options {
        add_ons {
            is_kubernetes_dashboard_enabled = false
            is_tiller_enabled = false
        }
        kubernetes_network_config {
            pods_cidr = "10.244.0.0/16"
            services_cidr = "10.96.0.0/16"
        }

        service_lb_subnet_ids = [oci_core_subnet.vcn-public-subnet.id]
    }
}