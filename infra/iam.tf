resource "google_service_account" "ingest" {
  project      = var.project_id
  account_id   = var.ingest_service_account_id
  display_name = "Student onboarding ingestion service account"
}

resource "google_storage_bucket_iam_member" "ingest_can_create_incoming_objects" {
  bucket = google_storage_bucket.d0_raw_landing.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.ingest.email}"

  condition {
    title       = "incoming-objects-only"
    description = "Allows uploads only to the incoming object prefix."
    expression  = "resource.type == 'storage.googleapis.com/Object' && resource.name.startsWith('projects/_/buckets/${google_storage_bucket.d0_raw_landing.name}/objects/incoming/')"
  }
}

resource "google_project_iam_member" "ingest_can_create_bigquery_jobs" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.ingest.email}"
}

resource "google_bigquery_dataset_iam_member" "ingest_can_stage_data" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.ingest.email}"
}

resource "google_bigquery_table_iam_member" "consumer_can_read_staged_table" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id   = google_bigquery_table.student_onboarding_staged.table_id
  role       = "roles/bigquery.dataViewer"
  member     = "group:${var.consumer_group}"
}
