resource "google_storage_bucket" "d0_raw_landing" {
  name                        = var.raw_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      num_newer_versions = 3
      with_state         = "ARCHIVED"
    }
  }

  labels = {
    data_layer  = "d0-raw"
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_bigquery_dataset" "d1_staged_enforced" {
  project                    = var.project_id
  dataset_id                 = var.dataset_id
  location                   = var.region
  delete_contents_on_destroy = false

  labels = {
    data_layer  = "d1-staged"
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_bigquery_table" "student_onboarding_staged" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.d1_staged_enforced.dataset_id
  table_id            = "student_onboarding_staged"
  deletion_protection = true

  schema = jsonencode([
    {
      name = "student_id"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "first_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "last_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "email"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "age"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "tenant_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "consent_confirmed"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "onboarding_approved"
      type = "BOOLEAN"
      mode = "REQUIRED"
    }
  ])
}
