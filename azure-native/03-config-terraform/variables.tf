variable "prefix" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "workspace_name" {
  type = string
}

variable "terraform_auth_path" {
  type = string
}

variable "terraform_auth_role" {
  type = string
}

variable "azure_secrets_engine_path" {
  type = string
}

variable "azure_secrets_engine_role" {
  type = string
}

variable "terraform_team_name" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}