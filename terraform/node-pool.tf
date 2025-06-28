resource "oci_containerengine_node_pool" "oke-node-pool" {
    cluster_id = oci_containerengine_cluster.oke-cluster.id
    compartment_id = oci_identity_compartment.tf-compartment.id
    kubernetes_version = "v1.33.1"
    name = "pool1"
    
    
    node_config_details {
      placement_configs {
        availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
        subnet_id = oci_core_subnet.vcn-private-subnet.id
      }
      size = 1
    }

    node_shape = "VM.Standard.A1.Flex"

    node_shape_config {
        memory_in_gbs = 6
        ocpus = 1
    }
    
    node_source_details {
      image_id = "ocid1.image.oc1.phx.aaaaaaaaxe2ivqoxeo4c3bgkeutfpod4oklzxmkrxgirgwgft2swftwcni2a"
      source_type = "image"
      boot_volume_size_in_gbs = 50
    }

    initial_node_labels {
        key = "name"
        value = "livekit-cluster"
    }
}