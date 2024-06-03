variable "vault_auth_path" {
  type = string
}

variable "vault_policy_name" {
  type = string
}

variable "vault_auth_role_name" {
  type = string
}

variable "terraform_addr" {
  type = string
}

variable "terraform_subject_identifier" {
  type = string
}

variable "terraform_token_ttl" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  sensitive = true
  type      = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_object_id" {
  type = string
}

variable "vault_azure_secrets_engine_path" {
  type = string
}

variable "terraform_token" {
  sensitive = true
}