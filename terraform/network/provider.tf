terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 7.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}

provider "google" {
  project     = "project-f53962c2-b852-4294-a0f"
  region      = "us-central1"
}
