# Local(s): Read Terraform Credentials from host configuration
locals {
  vault_permissions = {
    scope = [
      "User.Read"
    ]
    role = [
      "Application.ReadWrite.All",
      "GroupMember.ReadWrite.All"
    ]
  }
  onboarding_permissions = {
    scope = [
      "User.Read"
    ]
    role = [
      "Application.ReadWrite.All",
      "AppRoleAssignment.ReadWrite.All",
      "GroupMember.ReadWrite.All",
      "Group.ReadWrite.All"
    ]
  }
  azure_onboarding = {
    prefix = {
      content     = var.prefix
      category    = "terraform"
      description = "resource prefix"
    }
    TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE = {
      content     = vault_azure_secret_backend_role.this.role
      category    = "env"
      description = "vault azure secrets role for azure onboarding service principal"
    }
    TFC_VAULT_RUN_ROLE = {
      content     = vault_jwt_auth_backend_role.terraform.role_name
      category    = "env"
      description = "vault auth role for azure onboarding project"
    }
  }
  common_terraform_vault = {
    TFC_VAULT_ADDR = {
      content     = var.vault_addr
      category    = "env"
      description = "vault address"
    }
    TFC_VAULT_NAMESPACE = {
      content     = var.vault_namespace
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