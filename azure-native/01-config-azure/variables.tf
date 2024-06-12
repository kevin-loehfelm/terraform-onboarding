# vault root account for azure secrets engine
variable "app_vault_spn_name" {
  type = string
}

# vault management account for tfe onboarding
variable "app_tfe_onboarding_spn_name" {
  type = string
}