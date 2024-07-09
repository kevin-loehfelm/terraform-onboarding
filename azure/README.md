# Terraform On-boarding with native dynamic credentials

### Azure
data: current azuread configuration
data: azure native application ids
data: service prinicipal for Graph API
resource: application for Azure secrets engine integration (client id)
resource: service principal for Azure secrets engine integration
resource: client secret for service principal
resource: app role assignment to allow service principal to create/manage credentials

### Vault
resource: jwt auth mount for terraform vault-backed credentials
resource: vault policy for azure secrets engine
resource: jwt auth backend role to access secrets engines
resource: configure azure secrets mount with azure service principal
resource: azure secrets role to manage existing service principal
resource: terraform cloud secret backend
resource: terraform cloud secret role

### Terraform
data: read environment variables
resource: tfe project
resource: tfe variabiable set
resource: tfe variable: TFC_VAULT_ADDR
resource: tfe variable: TFC_VAULT_NAMESPACE
resource: tfe variable: TFC_VAULT_PROVIDER_AUTH
resource: tfe variable: TFC_VAULT_RUN_ROLE
resource: tfe variable: TFC_VAULT_AUTH_PATH
resource: tfe variable: TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE
resource: tfe variable: TFC_VAULT_BACKED_AZURE_PATH
resource: tfe variable: TFC_VAULT_BACKED_AZURE_MOUNT_PATH
resource: tfe variable: TFC_VAULT_BACKED_AZURE_SLEEP_SECONDS
resource: tfe variable set associated with the project
