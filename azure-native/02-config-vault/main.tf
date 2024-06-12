# Vault Auth Backend (jwt)
resource "vault_jwt_auth_backend" "terraform_auth" {
  description        = "JWT auth for Terraform Workload Identity"
  path               = var.terraform_auth_path
  oidc_discovery_url = var.terraform_addr
  bound_issuer       = var.terraform_addr
}

# Vault Policy for Terraform Workload Identity
resource "vault_policy" "terraform_auth" {
  name = var.terraform_auth_policy_name

  policy = templatefile("${path.module}/policy.tftpl", {
    azure_secrets_engine_path = var.azure_secrets_engine_path
    azure_secrets_engine_role = var.azure_secrets_engine_role
  })
}

# Vault Auth Backend (jwt) Role
resource "vault_jwt_auth_backend_role" "terraform_auth" {
  backend   = vault_jwt_auth_backend.terraform_auth.path
  role_name = var.terraform_auth_role
  token_policies = [
    "default",
    vault_policy.terraform_auth.name
  ]
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = var.terraform_workspace_subject_identifier
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = "600"
}

# Vault Azure Secrets Engine
resource "vault_azure_secret_backend" "terraform" {
  path            = var.azure_secrets_engine_path
  subscription_id = "unknown"
  description     = "Azure Secrets Engine for Terraform Workload Identity"
  tenant_id       = var.azure_tenant_id
  client_id       = var.app_vault_client_id
  client_secret   = var.app_vault_client_secret
  environment     = "AzurePublicCloud"
}

resource "vault_azure_secret_backend_role" "terraform" {
  backend               = vault_azure_secret_backend.terraform.path
  role                  = var.azure_secrets_engine_role
  application_object_id = var.app_tfe_onboarding_object_id
  ttl                   = 300
  max_ttl               = 600
}