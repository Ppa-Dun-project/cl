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

# Grant token creator permission (required for Workload Identity)
resource "google_project_iam_member" "token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.app_secrets.email}"
}

# Grant Artifact Registry reader on v1-mvp (images are stored there)
resource "google_project_iam_member" "ar_reader_sa" {
  project = "v1-mvp"
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.app_secrets.email}"
}

# Grant v2 default compute SA access to v1 Artifact Registry
resource "google_project_iam_member" "ar_reader_compute" {
  project = "v1-mvp"
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.v2.number}-compute@developer.gserviceaccount.com"
}

# Get v2 project number
data "google_project" "v2" {
  project_id = var.project_id
}

# ── Workload Identity bindings ──────────────────────────────────────

# ppa-dun-secrets-ksa (app namespace)
resource "google_service_account_iam_member" "workload_identity_ppa_dun" {
  service_account_id = google_service_account.app_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[app/ppa-dun-secrets-ksa]"
  depends_on         = [google_container_cluster.primary]
}

# api-secrets-ksa (app namespace) - kept for compatibility
resource "google_service_account_iam_member" "workload_identity_api" {
  service_account_id = google_service_account.app_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[app/api-secrets-ksa]"
  depends_on         = [google_container_cluster.primary]
}
