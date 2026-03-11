terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
