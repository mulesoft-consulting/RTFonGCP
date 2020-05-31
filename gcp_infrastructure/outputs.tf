output "google_compute_network_rtf-vpc_self_link" {
  value = "${google_compute_network.rtf-vpc.self_link}"
}

output "google_compute_subnetwork_rtf-subnet_self_link" {
  value = "${google_compute_subnetwork.rtf-subnet.self_link}"
}