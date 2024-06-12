terraform {
  required_providers {
    azuread = {
      version = ">= 2.50.0" # May 28, 2024
      source  = "hashicorp/azuread"
    }
  }
}