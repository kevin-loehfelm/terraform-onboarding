output "terraform_auth_role_name" {
  value = vault_jwt_auth_backend_role.terraform_auth.role_name
}

output "vault_auth_path" {
  value = vault_jwt_auth_backend.terraform_auth.path
}