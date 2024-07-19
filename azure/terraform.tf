terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azuread = {
      version = ">= 2.53.1" # Jul 19 2024
      source  = "hashicorp/azuread"
    }
    tfe = {
      version = ">= 0.57.0" # Jul 19 2024
      source  = "hashicorp/tfe"
    }
    time = {
      version = ">= 0.12.0" # Jul 19 2024
      source  = "hashicorp/time"
    }
    vault = {
      version = ">= 4.3.0" # Jul 19 2024
      source  = "hashicorp/vault"
    }
  }
}