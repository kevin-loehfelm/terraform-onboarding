resource "vault_jwt_auth_backend" "this" {
  description        = "Terraform JWT auth for dynamic credentials"
  path               = var.vault_auth_path
  oidc_discovery_url = var.terraform_addr
  bound_issuer       = var.terraform_addr
}

# vault policy
resource "vault_policy" "this" {
  name = var.vault_policy_name

  #policy = file("${path.module}/onboarding-permissions.policy")
  policy = templatefile("${path.module}/policy.tftpl", {
    azure_secrets_path = var.vault_azure_secrets_engine_path
    azure_auth_role    = var.vault_auth_role_name
  })
}

# vault jwt auth role
resource "vault_jwt_auth_backend_role" "this" {
  backend   = vault_jwt_auth_backend.this.path
  role_name = var.vault_policy_name
  token_policies = [
    "default",
    vault_policy.this.name
  ]
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = var.terraform_subject_identifier
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = var.terraform_token_ttl
}

resource "vault_azure_secret_backend" "this" {
  path            = var.vault_azure_secrets_engine_path
  subscription_id = "abc"
  description     = "tfe onboarding"
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  environment     = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "this" {
  backend               = var.vault_azure_secrets_engine_path
  role                  = "azure-native"
  application_object_id = var.azure_object_id
  ttl                   = "5m"
  max_ttl               = "10m"
}

resource "vault_terraform_cloud_secret_backend" "test" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = var.terraform_token.token
}

resource "vault_terraform_cloud_secret_role" "example" {
  backend      = vault_terraform_cloud_secret_backend.test.backend
  name         = "azure-secrets-engine"
  organization = "kloehfelm-demo"
  team_id      = var.terraform_token.team_id
}
