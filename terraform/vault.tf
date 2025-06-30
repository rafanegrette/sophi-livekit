# Create a Vault to store secrets
resource "oci_kms_vault" "livekit_vault" {
    compartment_id   = oci_identity_compartment.tf-compartment.id
    display_name     = "livekit-vault"
    vault_type       = "DEFAULT"
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Create a master encryption key
resource "oci_kms_key" "livekit_key" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    display_name   = "livekit-master-key"
    
    key_shape {
        algorithm = "AES"
        length    = 32
    }
    
    management_endpoint = oci_kms_vault.livekit_vault.management_endpoint
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Create a secret to store the GitHub PAT
resource "oci_vault_secret" "github_pat_secret" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    secret_name    = "github-pat-secret"
    vault_id       = oci_kms_vault.livekit_vault.id
    key_id         = oci_kms_key.livekit_key.id
    
    secret_content {
        content_type = "BASE64"
        content      = base64encode(var.github_access_token)
    }
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}
