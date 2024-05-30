resource "vault_jwt_auth_backend" "this" {
  description        = "Terraform JWT auth for dynamic credentials"
  path               = var.vault_auth_path
  oidc_discovery_url = var.terraform_addr
  bound_issuer       = var.terraform_addr
}

# vault policy
resource "vault_policy" "this" {
  name = var.vault_policy_name

  policy = file("${path.module}/onboarding-permissions.policy")
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