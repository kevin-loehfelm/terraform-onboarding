<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Usage

1. Clone this repository locally
2. Configure terraform.tfvars with environment specifics (reference sample terraform.tfvars.sample)
3. Configure environment

  - Login to Azure tenant with a credential authorized to create and grant administative access to service principals

    ```
    az login --tenant <tenant_id>
    ```

  - Login to HCP Terraform

    ```
    terraform login
    ```

  - Configure environment with a Vault token authorized for administraative access to Vault

    ```
    export VAULT_TOKEN=<vault_token>
    ```

4. Apply Terraform Configuration

  ```
  terraform init
  terraform plan
  terraform apply
  ```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.53.1 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | >= 0.57.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 4.3.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.onboarding](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.vault](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.onboarding](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.vault](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.onboarding](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.vault](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.vault](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [tfe_no_code_module.azure_native](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/no_code_module) | resource |
| [tfe_no_code_module.azure_vault_dynamic](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/no_code_module) | resource |
| [tfe_no_code_module.azure_vault_static](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/no_code_module) | resource |
| [tfe_project.dev](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_project.prod](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_project.stage](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_project.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_project_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) | resource |
| [tfe_project_variable_set.vault_auth](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) | resource |
| [tfe_project_variable_set.vault_azure](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) | resource |
| [tfe_registry_module.azure_native](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/registry_module) | resource |
| [tfe_registry_module.azure_vault_dynamic](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/registry_module) | resource |
| [tfe_registry_module.azure_vault_static](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/registry_module) | resource |
| [tfe_variable.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.vault_auth](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable.vault_azure](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_variable_set.vault_auth](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_variable_set.vault_azure](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [time_sleep.seconds_30](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [vault_azure_secret_backend.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/azure_secret_backend) | resource |
| [vault_azure_secret_backend_role.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/azure_secret_backend_role) | resource |
| [vault_jwt_auth_backend.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.terraform](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role) | resource |
| [vault_kv_secret_v2.github](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.terraform](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_mount.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_policy.terraform](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [tfe_github_app_installation.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/github_app_installation) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_repo_azure_native"></a> [github\_repo\_azure\_native](#input\_github\_repo\_azure\_native) | Variable(s): GitHub Workspace Module Repo for Onboarding with Azure Native Dynamic Credentials | `string` | n/a | yes |
| <a name="input_github_repo_azure_vault_dynamic"></a> [github\_repo\_azure\_vault\_dynamic](#input\_github\_repo\_azure\_vault\_dynamic) | Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with dynamic Service Principals | `string` | n/a | yes |
| <a name="input_github_repo_azure_vault_static"></a> [github\_repo\_azure\_vault\_static](#input\_github\_repo\_azure\_vault\_static) | Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with existing Service Principals | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | github token | `string` | n/a | yes |
| <a name="input_terraform_onboarding_project_name"></a> [terraform\_onboarding\_project\_name](#input\_terraform\_onboarding\_project\_name) | terraform project name: custom, * | `string` | n/a | yes |
| <a name="input_terraform_org_name"></a> [terraform\_org\_name](#input\_terraform\_org\_name) | terraform organization name | `string` | n/a | yes |
| <a name="input_terraform_token"></a> [terraform\_token](#input\_terraform\_token) | terraform token | `string` | n/a | yes |
| <a name="input_vault_addr"></a> [vault\_addr](#input\_vault\_addr) | vault address | `string` | n/a | yes |
| <a name="input_azure_app_azure_secrets_engine"></a> [azure\_app\_azure\_secrets\_engine](#input\_azure\_app\_azure\_secrets\_engine) | azure application name for vault azure secrets engine | `string` | `"vault-azure-secrets-engine"` | no |
| <a name="input_azure_app_onboarding"></a> [azure\_app\_onboarding](#input\_azure\_app\_onboarding) | azure application name for azure project onboarding | `string` | `"vault-azure-project-onboarding"` | no |
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | Variable(s): Default TTL for dynamic credentials (defualt: 300) | `number` | `300` | no |
| <a name="input_max_ttl"></a> [max\_ttl](#input\_max\_ttl) | Variable(s): Max TTL for dynamic credentials (defualt: 600) | `number` | `600` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | environment prefix | `string` | `"demo"` | no |
| <a name="input_terraform_addr"></a> [terraform\_addr](#input\_terraform\_addr) | terraform fqdn | `string` | `"https://app.terraform.io"` | no |
| <a name="input_terraform_variable_set_name"></a> [terraform\_variable\_set\_name](#input\_terraform\_variable\_set\_name) | terraform variable set for azure project onboarding | `string` | `"vault-azure-project-onboarding"` | no |
| <a name="input_vault_auth_path"></a> [vault\_auth\_path](#input\_vault\_auth\_path) | vault auth path for jwt auth | `string` | `"terraform"` | no |
| <a name="input_vault_auth_role_name"></a> [vault\_auth\_role\_name](#input\_vault\_auth\_role\_name) | vault auth role for azure project onboarding | `string` | `"azure_project_onboarding"` | no |
| <a name="input_vault_azure_secrets_path"></a> [vault\_azure\_secrets\_path](#input\_vault\_azure\_secrets\_path) | vault azure secrets mount path | `string` | `"azure"` | no |
| <a name="input_vault_azure_secrets_role"></a> [vault\_azure\_secrets\_role](#input\_vault\_azure\_secrets\_role) | vault azure secrets role | `string` | `"azure_project_onboarding"` | no |
| <a name="input_vault_namespace"></a> [vault\_namespace](#input\_vault\_namespace) | vault namespace | `string` | `""` | no |
| <a name="input_vault_policy_name"></a> [vault\_policy\_name](#input\_vault\_policy\_name) | vault policy name for terraform workload identity | `string` | `"azure_project_onboarding"` | no |
| <a name="input_vault_static_github_key"></a> [vault\_static\_github\_key](#input\_vault\_static\_github\_key) | kvv2 static secrets key | `string` | `"github"` | no |
| <a name="input_vault_static_secrets_path"></a> [vault\_static\_secrets\_path](#input\_vault\_static\_secrets\_path) | kvv2 static secrets mount path | `string` | `"static"` | no |
| <a name="input_vault_static_terraform_key"></a> [vault\_static\_terraform\_key](#input\_vault\_static\_terraform\_key) | kvv2 static secrets key | `string` | `"terraform"` | no |
| <a name="input_vault_terraform_secrets_path"></a> [vault\_terraform\_secrets\_path](#input\_vault\_terraform\_secrets\_path) | hcp terraform secrets mount path | `string` | `"terraform"` | no |
| <a name="input_vault_terraform_secrets_role"></a> [vault\_terraform\_secrets\_role](#input\_vault\_terraform\_secrets\_role) | hcp terraform secrets role | `string` | `"azure_project_onboarding"` | no |

## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->