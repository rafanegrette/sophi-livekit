## Create a Vault to store secrets
#resource "oci_kms_vault" "livekit_vault" {
#    compartment_id   = oci_identity_compartment.tf-compartment.id
#    display_name     = "livekit-vault"
#    vault_type       = "DEFAULT"
#    
#    freeform_tags = {
#        "Environment" = "development"
#        "Project"     = "livekit"
#    }
#}

data "oci_kms_vault" "livekit_vault" {
  # Paste the OCID of your existing vault here
  vault_id = "ocid1.vault.oc1.phx.efuh257yaaeto.abyhqljrwelaiwqrkhpfvacs7k4txbe3aph7iq7ml4izw5axb56o6ho3qiga"
  
}

# Create a master encryption key
resource "oci_kms_key" "livekit_key" {
    compartment_id = oci_identity_compartment.tf-compartment.id
    display_name   = "livekit-master-key"
    
    key_shape {
        algorithm = "AES"
        length    = 32
    }
    
    management_endpoint = data.oci_kms_vault.livekit_vault.management_endpoint
    
    freeform_tags = {
        "Environment" = "development"
        "Project"     = "livekit"
    }
}

# Create a secret to store the GitHub PAT
#resource "oci_vault_secret" "github_pat_secret3" {
#    compartment_id = oci_identity_compartment.tf-compartment.id
#    secret_name    = "github-pat-secret4"
#    vault_id       = data.oci_kms_vault.livekit_vault.id
#    key_id         = oci_kms_key.livekit_key.id
#    
#    secret_content {
#        content_type = "BASE64"
#        content      = base64encode(var.github_access_token)
#        stage = "CURRENT"
#    }
#    
#    freeform_tags = {
#        "Environment" = "development"
#        "Project"     = "livekit"
#    }
#}

data "oci_vault_secret" "github_pat_secret3" {
    secret_id = "ocid1.vaultsecret.oc1.phx.amaaaaaaovnrhfyacglezsfns7oxjeueaxfdpqmivobjbd4t2c2gsluffrga" 
}

