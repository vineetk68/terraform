# Provider Configuration
provider "google" {
  credentials = file("account.json")
  project     = "emerald-lattice-136623"
  region      = "us-central1"
}

# Google Cloud Storage Bucket 
resource "google_storage_bucket" "promo_app15_bucket" {
  name     = "promo.app15.in"
  location = "US"
  
  website {
    main_page_suffix = "index.html" # Main page (usually index.html)
    not_found_page   = "404.html"   # Page to be shown if requested content is not found.
  }
}

# SSL Certificate Creation
resource "google_compute_managed_ssl_certificate" "promo_app15_cert" {
  name        = "promo-app15-cert"
  description = "SSL Certificate for promo.app15.in"

  managed {
    domains = ["promo.app15.in"]
  }
}

# Load Balancer Configuration

# Backend Bucket Configuration for Load Balancer
resource "google_compute_backend_bucket" "promo_app15_backend_bucket" {
  name        = "promo-app15-backend-bucket"
  bucket_name = "promo-app15-in"
}

# URL Map Configuration for Load Balancer
resource "google_compute_url_map" "promo_app15_url_map" {
  name            = "promo-app15-url-map"
  default_service = google_compute_backend_bucket.promo_app15_backend_bucket.self_link
   host_rule {
    hosts        = ["promo.app15.in"]
    path_matcher = "redirect-path-matcher"
  }

  path_matcher {
    name            = "redirect-path-matcher"
    default_service = google_compute_backend_bucket.promo_app15_backend_bucket.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.promo_app15_backend_bucket.self_link
    }
  }

  test {
    host    = "promo.app15.in"
    path    = "/"
    service = google_compute_backend_bucket.promo_app15_backend_bucket.self_link
  }
}

# HTTPS Proxy Configuration for Load Balancer
resource "google_compute_target_https_proxy" "promo_app15_https_proxy" {
  name             = "promo-app15-https-proxy"
  url_map          = google_compute_url_map.promo_app15_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.promo_app15_cert.self_link]
}

# Global Address Configuration for Load Balancer
resource "google_compute_global_address" "promo_app15_address" {
  name = "promo-app15-global-address"
}

# HTTPS Forwarding Rule for Load Balancer
resource "google_compute_global_forwarding_rule" "promo_app15_https" {
  name       = "promo-app15-https-forwarding-rule"
  target     = google_compute_target_https_proxy.promo_app15_https_proxy.self_link
  port_range = "443"
  ip_address = google_compute_global_address.promo_app15_address.address
}

#Set Bucket Permissions
resource "google_storage_bucket_iam_binding" "promo_app15_bucket_public_read" {
  bucket = "promo-app15-in"
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers"
  ]
}

# HTTP Proxy Configuration for Load Balancer
resource "google_compute_target_http_proxy" "promo_app15_http_proxy" {
  name    = "promo-app15-http-proxy"
  url_map = google_compute_url_map.promo_app15_url_map.self_link
}

# HTTP Forwarding Rule for Load Balancer
resource "google_compute_global_forwarding_rule" "promo_app15_http" {
  name       = "promo-app15-http-forwarding-rule"
  target     = google_compute_target_http_proxy.promo_app15_http_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.promo_app15_address.address
}