terraform {
  required_providers {
    azuread = {
      version = ">= 2.52.0" # Jun 20 2024
      source  = "hashicorp/azuread"
    }
    external = {
      version = ">= 2.3.3" # Jun 20 2024
      source  = "hashicorp/external"
    }
    tfe = {
      version = ">= 0.56.0" # Jun 20 2024
      source  = "hashicorp/tfe"
    }
    time = {
      version = ">= 0.11.2" # Jun 20 2024
      source  = "hashicorp/time"
    }
    vault = {
      version = ">= 4.3.0" # Jun 20 2024
      source  = "hashicorp/vault"
    }
  }
}