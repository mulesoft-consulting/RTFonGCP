resource "google_compute_disk" "rtf-controller-etcd" {
  name  = "rtf-controller-etcd-${var.postfix}"
  type  = "pd-ssd"
  zone = var.zone[0]
  size = 100
}

resource "google_compute_disk" "rtf-controller-docker" {
  name  = "rtf-controller-docker-${var.postfix}"
  type  = "pd-ssd"
  zone = var.zone[0]
  size = 100
}

resource "google_compute_disk" "rtf-worker1-docker" {
  name  = "rtf-worker1-docker-${var.postfix}"
  type  = "pd-ssd"
  zone = var.zone[1]
  size = 100
}

resource "google_compute_disk" "rtf-worker2-docker" {
  name  = "rtf-worker2-docker-${var.postfix}"
  type  = "pd-ssd"
  zone = var.zone[2]
  size = 100
}