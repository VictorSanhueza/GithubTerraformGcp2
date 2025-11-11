# ====== Outputs ======
output "function_name" {
  value = google_cloudfunctions2_function.hello.name
}

# URL pública: la expone Cloud Functions v2 como "service_config[0].uri" (provider >= 5.x)
output "function_url" {
  value = google_cloudfunctions2_function.hello.service_config[0].uri
}