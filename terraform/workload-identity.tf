# GCP Service Account for accessing Secret Manager
resource "google_service_account" "app_secrets" {
  account_id   = "app-secrets-sa"
  display_name = "App Secrets Service Account"
}

# Grant Secret Manager access to the SA
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.app_secrets.email}"
}

# Allow K8s Service Account to use GCP Service Account (Workload Identity binding)
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.app_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[app/app-secrets-ksa]"
}
