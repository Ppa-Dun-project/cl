# GCS bucket for API frontend static files
resource "google_storage_bucket" "api_frontend" {
  name          = "v2-api-ppa-dun"
  location      = var.region
  force_destroy                = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Make bucket publicly readable
resource "google_storage_bucket_iam_member" "api_frontend_public" {
  bucket = google_storage_bucket.api_frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Backend bucket for CDN
resource "google_compute_backend_bucket" "api_frontend_cdn" {
  name        = "api-frontend-cdn"
  bucket_name = google_storage_bucket.api_frontend.name
  enable_cdn  = true
}
