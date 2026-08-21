output "raw_bucket_name" {
  description = "Name of the D0 raw landing bucket."
  value       = google_storage_bucket.d0_raw_landing.name
}

output "staged_dataset_id" {
  description = "Fully qualified D1 staged dataset ID."
  value       = "${google_bigquery_dataset.d1_staged_enforced.project}.${google_bigquery_dataset.d1_staged_enforced.dataset_id}"
}

output "ingest_service_account_email" {
  description = "Email of the service account used for controlled ingestion."
  value       = google_service_account.ingest.email
}

output "staged_table_id" {
  description = "Fully qualified staged student onboarding table ID."
  value       = "${var.project_id}.${google_bigquery_dataset.d1_staged_enforced.dataset_id}.${google_bigquery_table.student_onboarding_staged.table_id}"
}
