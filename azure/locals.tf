# Local(s): Read Terraform Credentials from host configuration
locals {
  tfe_credentials = jsondecode(file("~/.terraform.d/credentials.tfrc.json"))
  terraform_onboarding = {
    prefix = {
      content     = var.prefix
      category    = "terraform"
      description = "resource prefix"
    }
    TFC_VAULT_RUN_ROLE = {
      content     = vault_jwt_auth_backend_role.terraform.role_name
      category    = "env"
      description = "vault auth role"
    }
    TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE = {
      content     = vault_azure_secret_backend_role.this.role
      category    = "env"
      description = "vault-backed azure credential role"
    }
  }
  common_terraform_vault = {
    TFC_VAULT_ADDR = {
      content     = data.external.env.result.VAULT_ADDR
      category    = "env"
      description = "vault address"
    }
    TFC_VAULT_NAMESPACE = {
      content     = data.external.env.result.VAULT_NAMESPACE
      category    = "env"
      description = "vault namespace"
    }
    TFC_VAULT_PROVIDER_AUTH = {
      content     = true
      category    = "env"
      description = "enable vault dynamic credentials"
    }
    TFC_VAULT_AUTH_PATH = {
      content     = vault_jwt_auth_backend.this.path
      category    = "env"
      description = "vault auth path"
    }
  }
  common_terraform_vault_azure = {
    TFC_VAULT_BACKED_AZURE_AUTH = {
      content     = true
      category    = "env"
      description = "enable vault-backed azure dynamic credentials"
    }
    TFC_VAULT_BACKED_AZURE_MOUNT_PATH = {
      content     = vault_azure_secret_backend.this.path
      category    = "env"
      description = "vault azure secrets engine path"
    }
    TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS = {
      content     = 30
      category    = "env"
      description = "vault azure injected delay for eventual consistency"
    }
  }
}