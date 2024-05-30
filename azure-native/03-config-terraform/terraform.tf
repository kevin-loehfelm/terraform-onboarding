terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe" # Inherited from root or latest
    }
    external = {
      source = "hashicorp/external" # Inherited from root or latest
    }
  }
}