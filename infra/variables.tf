variable "project_id" {
  description = "Google Cloud project ID that will contain the resources."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "Google Cloud region for the bucket and BigQuery dataset."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Short environment label used in resource labels."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "raw_bucket_name" {
  description = "Globally unique name for the D0 raw landing bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,220}[a-z0-9]$", var.raw_bucket_name))
    error_message = "raw_bucket_name must use a valid Cloud Storage bucket naming pattern."
  }
}

variable "dataset_id" {
  description = "BigQuery dataset ID for D1 staged and enforced data."
  type        = string
  default     = "d1_staged_enforced"

  validation {
    condition     = can(regex("^[A-Za-z_][A-Za-z0-9_]*$", var.dataset_id)) && length(var.dataset_id) <= 1024
    error_message = "dataset_id must contain only letters, numbers, and underscores, cannot begin with a number, and must be at most 1,024 characters."
  }
}

variable "ingest_service_account_id" {
  description = "Account ID for the service account that writes raw files and stages data."
  type        = string
  default     = "student-ingest"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.ingest_service_account_id))
    error_message = "ingest_service_account_id must be a valid service account ID."
  }
}

variable "consumer_group" {
  description = "Google group allowed to query filtered staged student data."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.consumer_group))
    error_message = "consumer_group must be an email address for a Google group."
  }
}

variable "consumer_tenant_code" {
  description = "Tenant code that the configured consumer group may read."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,64}$", var.consumer_tenant_code))
    error_message = "consumer_tenant_code must contain only letters, numbers, hyphens, or underscores."
  }
}
