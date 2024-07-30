<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
# Terraform Onboarding

This repository contains the Terraform code for initial setup of the demo environment. 

| Repository | Description |
|------------|-------------|
| [kevin-loehfelm/terraform-onboarding](https://github.com/kevin-loehfelm/terraform-onboarding) | Repository for Terraform-driven automated onboarding |
| [kevin-loehfelm/terraform-onboarding-azure-native-project](https://github.com/kevin-loehfelm/terraform-onboarding-azure-native-project) | No-Code Module for deploying an Azure project with Azure Federated Identities |
| [kevin-loehfelm/template-azure-native-project](https://github.com/kevin-loehfelm/template-azure-native-project) | Template repository for Project using Azure Federated Identities |
| [kevin-loehfelm/terraform-onboarding-azure-vault-backed-static-project](https://github.com/kevin-loehfelm/terraform-onboarding-azure-vault-backed-static-project) | No-Code Module for deploying an Azure project with Vault-backed credentials using persistent Service Principals |
| [kevin-loehfelm/terraform-onboarding-azure-vault-backed-dynamic-project](https://github.com/kevin-loehfelm/terraform-onboarding-azure-vault-backed-dynamic-project) | No-Code Module for deploying an Azure project with Vault-backed credentials using dynamic Service Principals |
| [kevin-loehfelm/template-azure-vault-backed-project](https://github.com/kevin-loehfelm/template-azure-vault-backed-project) | Template repository for Project using Vault-backed Azure Credentials |

## Deployment

1. Clone this repository
2. Change to the working directory ```azure/```
3. Configure the environment per prerequisites section
    1. [Configure Environment](#configure-environment)
    2. [Configure Terraform Variables](#configure-terraform-variables)
4. Initialize Terraform configuration
    ```
    terraform init
    ```
5. Validate environment. Resolve any errors.
    ```
    terraform validate
    ```
6. Review Terraform plan and apply changes.
    ```
    terraform plan
    terraform apply
    ```

### Configure Environment

Providers are configured to use environment context for authority to create resources.

* **azuread**
    * Required Authorization:
        * Create Azure Entra ID Application
        * Create Azure Entra ID Service Principal
        * Assign Azure Entra ID Permissions
        * Grant Admin Consent for Administrative Permissions
    * Login with Azure CLI:
        ```
        az login --tenant <tenant_id>
        ```
* **tfe**
    * Required Authorization:
        * Create Terraform Projects
        * Create Terraform Variable Sets
        * Create Terraform Variables
        * Publish Modules to the PMR
    * Login to HCP Terraform or Terraform Enterprise:
        ```
        terraform login [hostname]
        ```
* **vault**
    * Required Authorization:
        * Create Vault Policy
        * Enable/Configure Auth Mount (jwt)
        * Enable/Configure Secrets Engine (azure)
        * Enable/Configure Secrets Engine (terraform)
        * Enable/Configure Secrets Engine (kv v2)
        * Write KV v2 Secrets
    * Configure Vault Address and Namespace as terraform variables
        * vault_addr
        * vault_namespace
    * Configure Environment Variable with a Vault Token
        ```
        export VAULT_TOKEN=<vault_token>
        ````

### Configure Terraform Variables

Customize Terraform variables for the deployment environment. A sample [terraform.tfvars](./terraform.tfvars.sample) is provided

### Deployment Details

This project deploys and configures the following:

1. **Vault** | Create Policy authorizing request of platform credentials for project onboarding
2. **Vault** | Enable KV v2 Secrets Engine (for storing static credentials)
3. **Vault** | Write Static HCP Terraform token to KV secrets engine
4. **Vault** | Write Static GitHub token to KV secrets engine
5. **Vault** | Enable & Configure JWT Auth Mount (for authenticating HCP Terraform)
6. **Vault** | Create JWT auth role to authenticate HCP Terraform project onboarding project
7. **Azure** | Service Principal to configure Azure Secrets Engine
8. **Azure** | Authorize Azure Secrets Engine Service Principal
    1. `Application.ReadWrite.All`
    2. `GroupMember.ReadWrite.All`
9. **Azure** | Service Principal to support project onboarding
10. **Azure** | Authorize Project Onboarding Service Principal
    1. `Application.ReadWrite.All`
    2. `AppRoleAssignment.ReadWrite.All`
    3. `Group.ReadWrite.All`
    4. `GroupMember.ReadWrite.All`
11. **Vault** | Enable & Configure Azure Secrets Engine
12. **Vault** | Azure Secrets Engine role for project onboarding
13. **Terraform** | Create a Terraform project for Project Onboarding
14. **Terraform** | Create a Terraform project for Production Workspaces
15. **Terraform** | Create a Terraform project for Staging Workspaces
16. **Terraform** | Create a Terraform project for Development Workspaces
17. **Terraform** | Publish module: Project Onboarding with Azure Federated Identities
18. **Terraform** | Enable No-Code module: Project Onboarding with Azure Federated Identities
19. **Terraform** | Publish module: Project Onboarding using Vault-Backed credentials with persistent Service Principals
20. **Terraform** | Enable No-Code module: Project Onboarding using Vault-Backed credentials with persistent Service Principals
21. **Terraform** | Publish module: Project Onboarding using Vault-Backed credentials with dynamic Service Principals
22. **Terraform** | Enable No-Code module: Project Onboarding using Vault-Backed credentials with dynamic Service Principals
23. **Terraform** | Create Variable Set: HCP Terraform to Vault dynamic credentials configuration
    1) **Terraform** | Create Variables
        1. `TFC_VAULT_PROVIDER_AUTH`
        2. `TFC_VAULT_ADDR`
        3. `TFC_VAULT_NAMESPACE`
        4. `TFC_VAULT_AUTH_PATH`
24. **Terraform** | Create Variable Set: HCP Terraform to Vault-backed Azure dynamic credentials configuration
    1. **Terraform** | Create Variables
        1. `TFC_VAULT_BACKED_AZURE_AUTH`
        2. `TFC_VAULT_BACKED_AZURE_MOUNT_PATH`
        3. `TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS`
25. **Terraform** | Create Variable Set: Project Onboarding Roles & Context
    1. **Terraform** | Create Variables
        1. `TFC_VAULT_RUN_ROLE`
        2. `TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE`
        3. `prefix`

## Usage

After initial deployment, the Terraform organization should be enabled with three No-Code modules:

* azure-native-project
* azure-vault-backed-static-project
* azure-vault-backed-dynamic-project

![alt_text](./images/terraform-registry-no-code-modules.png "Terraform Registry | No-Code Module(s)")

### Usage Details

1. Select the preferred No-Code module
2. Select ‘Provision workspace’
3. Provide a project name in the ‘project_name’ field
4. Select ‘Next: Workspace settings’
5. Provide a workspace name in the ‘Workspace name’ field
6. Select the ‘azure-onboarding’ project under Project
7. Select ‘Create workspace’

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
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | github organization name | `string` | n/a | yes |
| <a name="input_github_repo_azure_native"></a> [github\_repo\_azure\_native](#input\_github\_repo\_azure\_native) | Variable(s): GitHub Workspace Module Repo for Onboarding with Azure Native Dynamic Credentials | `string` | n/a | yes |
| <a name="input_github_repo_azure_vault_dynamic"></a> [github\_repo\_azure\_vault\_dynamic](#input\_github\_repo\_azure\_vault\_dynamic) | Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with dynamic Service Principals | `string` | n/a | yes |
| <a name="input_github_repo_azure_vault_static"></a> [github\_repo\_azure\_vault\_static](#input\_github\_repo\_azure\_vault\_static) | Variable(s): GitHub Workspace Module Repo for Onboarding with Vault-Backed Azure Dynamic Credentials with existing Service Principals | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | github token | `string` | n/a | yes |
| <a name="input_terraform_org_name"></a> [terraform\_org\_name](#input\_terraform\_org\_name) | terraform organization name | `string` | n/a | yes |
| <a name="input_terraform_token"></a> [terraform\_token](#input\_terraform\_token) | terraform token | `string` | n/a | yes |
| <a name="input_vault_addr"></a> [vault\_addr](#input\_vault\_addr) | vault address | `string` | n/a | yes |
| <a name="input_azure_app_azure_secrets_engine"></a> [azure\_app\_azure\_secrets\_engine](#input\_azure\_app\_azure\_secrets\_engine) | azure application name for vault azure secrets engine | `string` | `"vault-azure-secrets-engine"` | no |
| <a name="input_azure_app_onboarding"></a> [azure\_app\_onboarding](#input\_azure\_app\_onboarding) | azure application name for azure project onboarding | `string` | `"vault-azure-project-onboarding"` | no |
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | Variable(s): Default TTL for dynamic credentials (defualt: 300) | `number` | `300` | no |
| <a name="input_max_ttl"></a> [max\_ttl](#input\_max\_ttl) | Variable(s): Max TTL for dynamic credentials (defualt: 600) | `number` | `600` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | environment prefix | `string` | `"demo"` | no |
| <a name="input_terraform_addr"></a> [terraform\_addr](#input\_terraform\_addr) | terraform fqdn | `string` | `"https://app.terraform.io"` | no |
| <a name="input_terraform_onboarding_project_name"></a> [terraform\_onboarding\_project\_name](#input\_terraform\_onboarding\_project\_name) | terraform project name: custom, * | `string` | `"azure-onboarding"` | no |
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