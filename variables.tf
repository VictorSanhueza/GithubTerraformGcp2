variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "vm_name" {
  description = "Nombre de la VM"
  type        = string
  default     = "demo-gha-tf-vm"
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
  default     = "e2-micro"
}

variable "service_account_email" {
  description = "Service Account que se adjunta a la VM (opcional)"
  type        = string
  default     = null
}

variable "function_name" {
  description = "Nombre de la Cloud Function"
  type        = string
  default     = "hello-fn"
}