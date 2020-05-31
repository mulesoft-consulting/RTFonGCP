resource "google_compute_network" "rtf-vpc" {
  auto_create_subnetworks         = "false"
  delete_default_routes_on_create = "false"
  name                            = "rtf-vpc-${var.postfix}"
  project                         = "mulesoft-pre-sales-sandbox"
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "rtf-subnet" {
  ip_cidr_range            = "10.0.0.0/16"
  name                     = "rtf-subnet-${var.postfix}"
  network                  = google_compute_network.rtf-vpc.self_link
  private_ip_google_access = "false"
  project                  = "mulesoft-pre-sales-sandbox"
  region                   = "us-west1"
}

resource "google_compute_firewall" "rtf-allow-https" {
  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  direction      = "INGRESS"
  disabled       = "false"
  enable_logging = "false"
  name           = "rtf-allow-https-${var.postfix}"
  network        = google_compute_network.rtf-vpc.self_link
  priority       = "1000"
  project        = "mulesoft-pre-sales-sandbox"
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["rtf-allow-https"]
}

resource "google_compute_firewall" "rtf-allow-install" {
  allow {
    ports    = ["4242", "61008-61010", "61022-61024"]
    protocol = "tcp"
  }

  direction      = "INGRESS"
  disabled       = "false"
  enable_logging = "false"
  name           = "rtf-allow-install-${var.postfix}"
  network        = google_compute_network.rtf-vpc.self_link
  priority       = "1000"
  project        = "mulesoft-pre-sales-sandbox"
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["rtf-allow-install"]
}

resource "google_compute_firewall" "rtf-allow-internal" {
  allow {
    protocol = "all"
  }

  direction      = "INGRESS"
  disabled       = "false"
  enable_logging = "false"
  name           = "rtf-allow-internal-${var.postfix}"
  network        = google_compute_network.rtf-vpc.self_link
  priority       = "1000"
  project        = "mulesoft-pre-sales-sandbox"
  source_ranges  = ["10.0.0.0/16"]
  target_tags    = ["rtf-allow-internal"]
}

resource "google_compute_firewall" "rtf-allow-ops-center" {
  allow {
    ports    = ["32009"]
    protocol = "tcp"
  }

  direction      = "INGRESS"
  disabled       = "false"
  enable_logging = "false"
  name           = "rtf-allow-ops-center-${var.postfix}"
  network        = google_compute_network.rtf-vpc.self_link
  priority       = "1000"
  project        = "mulesoft-pre-sales-sandbox"
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["rtf-allow-ops-center"]
}

resource "google_compute_firewall" "rtf-allow-ssh" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction      = "INGRESS"
  disabled       = "false"
  enable_logging = "false"
  name           = "rtf-allow-ssh-${var.postfix}"
  network        = google_compute_network.rtf-vpc.self_link
  priority       = "1000"
  project        = "mulesoft-pre-sales-sandbox"
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["rtf-allow-ssh"]
}

resource "google_compute_firewall" "rtf-allow-egress" {
  allow {
    ports    = ["123"]
    protocol = "udp"
  }

  allow {
    ports    = ["443", "5044"]
    protocol = "tcp"
  }

  destination_ranges = ["0.0.0.0/0"]
  direction          = "EGRESS"
  disabled           = "false"
  enable_logging     = "false"
  name               = "rtf-allow-egress-${var.postfix}"
  network            = google_compute_network.rtf-vpc.self_link
  priority           = "1000"
  project            = "mulesoft-pre-sales-sandbox"
  target_tags        = ["rtf-allow-egress"]
}