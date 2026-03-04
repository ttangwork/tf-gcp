terraform {
  backend "gcs" {
    bucket = "tf-gcp-state-gcs"
    prefix = "terraform/state"
  }
}
