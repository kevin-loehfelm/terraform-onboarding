terraform {
  required_providers {
    azuread = {
      version = ">= 2.50.0" # May 28, 2024
      source  = "hashicorp/azuread"
    }
    external = {
      version = ">= 2.3.3"
      source = "hashicorp/external"
    }
    tfe = {
      version = ">= 0.55.0" # May 28, 2024
      source  = "hashicorp/tfe"
    }
    time = {
      version = ">= 0.11.2" # Jun 06 2024
      source  = "hashicorp/time"
    }
    vault = {
      version = ">= 4.2.0" # May 28, 2024
      source  = "hashicorp/vault"
    }
  }
}