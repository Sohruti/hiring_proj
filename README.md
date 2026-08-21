# Junior Cloud & DevOps Engineer Assignment

This repository contains a deliberately small implementation of three assignment tasks: Terraform for a basic GCP data landing/staging design, a fail-closed GitHub Actions quality gate, and a minimal Django REST Framework (DRF) onboarding API. It is a **demonstration project**, not a production system. It has no frontend, containers, Kubernetes, remote Terraform backend, production deployment, real credentials, or unnecessary cloud services.

## Repository layout

```text
.
├── .github/workflows/ci.yml       # Fail-closed CI quality gates
├── infra/                         # Terraform for GCP storage, BigQuery, IAM, and RLS
├── student_onboarding/            # Minimal Django/DRF API and tests
├── .gitleaks.toml                 # Secret scanner configuration
└── README.md                      # Scope, assumptions, and commands
```

## Design and security choices

The D0 raw landing bucket uses uniform bucket-level access and public access prevention. Uniform bucket-level access removes object ACL access controls in favour of IAM, making a small IAM model easier to review.[1] Public access prevention blocks public ACLs and public IAM bindings for the bucket.[2]

| Component | Design choice | Reason |
|---|---|---|
| **D0 Raw Landing** | GCS bucket with uniform bucket-level access, public-access prevention, object versioning, and a short archived-version cleanup rule. | The landing area is private by default and has minimal recovery protection without introducing another service. |
| **Ingestion IAM** | One service account gets `roles/storage.objectCreator` only, with an IAM condition limited to `incoming/`; it also has only the BigQuery job and D1 data-editor roles needed to stage files. | The account cannot read or delete raw objects, and bucket writes are limited to an explicit prefix. |
| **D1 Staged/Enforced** | One BigQuery dataset and one illustrative staged table. | It demonstrates the requested D1 layer without inventing a broader data platform. |
| **Consumer access** | A Google group has viewer access to the one staged table, and an RLS policy limits it to one configured tenant code. | BigQuery row access policies filter table rows for named grantees while normal table access remains controlled separately.[3] |
| **Infrastructure state** | No remote backend. | This is intentional assignment scope. Do not use it for shared production state. |

## Assumptions

| Topic | Assumption |
|---|---|
| **Inputs** | The deploying user supplies a GCP project ID, globally unique bucket name, consumer Google group, and permitted tenant code. No real values or credentials are committed. |
| **D0 contents** | Raw files are written beneath `incoming/`. Retaining current data indefinitely and deleting archived versions after three newer copies is adequate for this exercise. |
| **People and identities** | Only the application ingestion service account and one consumer Google group are modelled. Existing platform administrators and provider service agents are outside this repository because no identities were supplied. |
| **RLS model** | `student_onboarding_staged` is a sample table used to demonstrate tenant-based row filtering. A real multi-tenant design could require one policy per consumer group or a centrally managed entitlement table. |
| **DRF payload** | The API accepts `student_id`, `first_name`, `last_name`, `email`, `age`, `tenant_code`, and `consent_confirmed`. It does not accept identity documents, payment data, authentication data, or other sensitive information. |
| **DCYN decision** | **Decision Criteria: Yes/No (DCYN)** is approved only when all validation succeeds and `consent_confirmed` is the JSON boolean `true`. The project does not implement admissions, credit, employment, or eligibility decisions. |
| **Database** | SQLite is used only for local development and automated tests. |

## Local verification

Install Terraform and Python 3.9 or later. The CI workflow uses Python 3.12. From the repository root, run the commands below.

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with non-secret values for a GCP project you control.
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

Terraform validation checks configuration syntax and internal consistency; it does not create GCP resources. Applying this configuration is intentionally left as a deliberate, credentialed action and requires GCP permissions to create the listed resources and policies.

```bash
cd ../student_onboarding
python -m venv .venv
source .venv/bin/activate
python -m pip install --requirement requirements.txt
ruff check .
python manage.py test
```

## CI quality gates

The `.github/workflows/ci.yml` workflow runs in one ordered job. It performs secret scanning with Gitleaks, Terraform formatting, backend-free Terraform initialization and validation, Ruff linting, and Django tests. There is no `continue-on-error`, no permissive condition, and no independent downstream job. Therefore, a failed security or quality step exits the job and prevents later steps from running.

## API behaviour

The endpoint is `POST /api/onboarding/`. It has one create-only purpose. `StudentOnboardingSerializer` validates required fields, exact JSON types, field lengths, integer ranges, email format, and the tenant-code format before creation. Type coercion is rejected: for example, `"18"` is not accepted for `age`, and `1` is not accepted for `consent_confirmed`.

```json
{
  "student_id": 1001,
  "first_name": "Amina",
  "last_name": "Patel",
  "email": "amina.patel@example.com",
  "age": 18,
  "tenant_code": "TENANT_A",
  "consent_confirmed": true
}
```

A valid request creates a record with `onboarding_approved: true`. A missing, malformed, out-of-range, or non-consenting request returns HTTP 400 and creates no record.

## References

[1]: https://cloud.google.com/storage/docs/uniform-bucket-level-access "Cloud Storage: Uniform bucket-level access"
[2]: https://cloud.google.com/storage/docs/public-access-prevention "Cloud Storage: Public access prevention"
[3]: https://cloud.google.com/bigquery/docs/row-level-security-intro "BigQuery: Introduction to row-level security"
