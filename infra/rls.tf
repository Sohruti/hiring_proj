resource "google_bigquery_row_access_policy" "consumer_tenant_filter" {
  project          = var.project_id
  dataset_id       = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id         = google_bigquery_table.student_onboarding_staged.table_id
  policy_id        = "consumer-tenant-filter"
  filter_predicate = "tenant_code = '${var.consumer_tenant_code}'"
  grantees         = ["group:${var.consumer_group}"]
}
