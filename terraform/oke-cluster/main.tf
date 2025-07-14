# OKE Cluster
resource "oci_containerengine_cluster" "oke-cluster" {
    compartment_id = var.compartment_id
    kubernetes_version = var.kubernetes_version
    name = var.cluster_name
    vcn_id = var.vcn_id

    options {
        add_ons {
            is_kubernetes_dashboard_enabled = var.is_kubernetes_dashboard_enabled
            is_tiller_enabled = var.is_tiller_enabled
        }
        kubernetes_network_config {
            pods_cidr = var.pods_cidr
            services_cidr = var.services_cidr
        }

        service_lb_subnet_ids = var.service_lb_subnet_ids
    }
}


# Node Pool
resource "oci_containerengine_node_pool" "oke-node-pool" {
    cluster_id = oci_containerengine_cluster.oke-cluster.id
    compartment_id = var.compartment_id
    kubernetes_version = var.kubernetes_version
    name = var.node_pool_name
    
    node_config_details {
      placement_configs {
        availability_domain = var.availability_domain
        subnet_id = var.private_subnet_id
      }
      size = var.node_pool_size
    }

    node_shape = var.node_shape

    node_shape_config {
        memory_in_gbs = var.node_memory_in_gbs
        ocpus = var.node_ocpus
    }
    
    node_source_details {
      image_id = var.node_image_id
      source_type = "image"
      boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    }

    initial_node_labels {
        key = var.node_label_key
        value = var.node_label_value
    }
}

# Artifact Registry
resource "oci_artifacts_container_repository" "livekit_repository" {
    compartment_id = var.compartment_id
    display_name   = var.repository_name
    is_immutable   = var.repository_is_immutable
    is_public      = var.repository_is_public
    
    readme {
        content = var.repository_readme_content
        format  = var.repository_readme_format
    }
}

# Data source to get the container registry
data "oci_artifacts_container_configuration" "container_configuration" {
    compartment_id = var.compartment_id
}

# Kubernetes provider configuration
data "oci_containerengine_cluster_kube_config" "cluster_kube_config" {
  cluster_id = oci_containerengine_cluster.oke-cluster.id
  expiration = 2592000
}

provider "kubernetes" {
  host                   = yamldecode(data.oci_containerengine_cluster_kube_config.cluster_kube_config.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.cluster_kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args = [
      "ce",
      "cluster",
      "generate-token",
      "--cluster-id",
      oci_containerengine_cluster.oke-cluster.id
    ]
  }
}

# Create namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.app_namespace
  }
  
  depends_on = [oci_containerengine_node_pool.oke-node-pool]
}