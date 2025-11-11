# ====== APIs necesarias ======
resource "google_project_service" "cloudfunctions" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# ====== Bucket para el código de la función ======
resource "google_storage_bucket" "functions_src" {
  name          = "${var.project_id}-functions-src"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}

# ====== Zip del código (desde function_src/) ======
data "archive_file" "fn_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function_src"
  output_path = "${path.module}/function_src.zip"
}

# Subimos el zip al bucket
resource "google_storage_bucket_object" "fn_obj" {
  name   = "helloworld-${data.archive_file.fn_zip.output_md5}.zip"
  bucket = google_storage_bucket.functions_src.name
  source = data.archive_file.fn_zip.output_path
}

# ====== Service Account que usará la función ======
resource "google_service_account" "fn_runner" {
  account_id   = "cf-hello-runner"
  display_name = "CF Hello Runner"
}

# ====== Cloud Function 2ª gen (HTTP) ======
resource "google_cloudfunctions2_function" "hello" {
  name        = var.function_name
  location    = var.region
  description = "Hello World via Terraform + GHA"

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.run,
    google_project_service.cloudbuild
  ]

  build_config {
    runtime     = "python311"
    entry_point = "hello_http"

    source {
      storage_source {
        bucket = google_storage_bucket.functions_src.name
        object = google_storage_bucket_object.fn_obj.name
      }
    }
  }

  service_config {
    available_memory    = "256M"
    timeout_seconds     = 60
    ingress_settings    = "ALLOW_ALL"  # permite tráfico público
    service_account_email = google_service_account.fn_runner.email
    environment_variables = {
      APP_ENV = "prod"
    }
  }
}

# ====== Permiso para invocación anónima (pública) ======
# La función v2 corre en Cloud Run. Damos run.invoker a allUsers.
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  location = google_cloudfunctions2_function.hello.location
  name     = google_cloudfunctions2_function.hello.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
