terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }

backend "gcs" {
    bucket = "optical-depth-472215-h9-tfstate"  # ya existe
    prefix = "function/state"                  # “carpeta” lógica
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
