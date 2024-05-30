terraform {
  required_providers {
    vault = {
      version = ">= 4.2.0" # May 28, 2024
      source  = "hashicorp/vault"
    }
    azuread = {
      version = ">= 2.50.0" # May 28, 2024
      source  = "hashicorp/azuread"
    }
    tfe = {
      version = ">= 0.55.0" # May 28, 2024
      source  = "hashicorp/tfe"
    }
  }
}