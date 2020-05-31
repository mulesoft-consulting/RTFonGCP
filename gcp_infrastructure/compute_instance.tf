resource "google_compute_instance" "rtf-controller" {
  attached_disk {
    mode        = "READ_WRITE"
    source      = google_compute_disk.rtf-controller-etcd.self_link
  }

  attached_disk {
    mode        = "READ_WRITE"
    source      = google_compute_disk.rtf-controller-docker.self_link
  }

  boot_disk {
    auto_delete = "true"
    device_name = "rtf-controller-${var.postfix}"

    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/rhel-cloud/global/images/rhel-7-v20200521"
      size  = "80"
      type  = "pd-standard"
    }

    mode   = "READ_WRITE"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"
  machine_type        = "custom-2-8192"
  name                = "rtf-controller-${var.postfix}"

  network_interface {
    network            = google_compute_network.rtf-vpc.self_link
    network_ip         = "10.0.0.5"
    subnetwork         = google_compute_subnetwork.rtf-subnet.self_link

    access_config {
      // Ephemeral IP
    }    
  }

  tags = ["rtf-allow-install", "rtf-allow-ops-center", "rtf-allow-egress", "rtf-allow-internal", "rtf-allow-ssh", "rtf-allow-https"]
  zone = var.zone[0]

  metadata_startup_script = <<SCRIPT
      yum install zip unzip -y
      sudo -u ${var.gcp_user} curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/scripts/latest --output /home/${var.gcp_user}/rtf-install-scripts.zip
      sudo -u ${var.gcp_user} mkdir -p /home/${var.gcp_user}/rtf-install-scripts && unzip /home/${var.gcp_user}/rtf-install-scripts.zip -d /home/${var.gcp_user}/rtf-install-scripts
      chown ${var.gcp_user}:${var.gcp_user} -R /home/${var.gcp_user}/rtf-install-scripts
      mkdir -p /opt/anypoint/runtimefabric
      chown ${var.gcp_user}:${var.gcp_user} /opt/anypoint/runtimefabric
      sudo -u ${var.gcp_user} cp /home/${var.gcp_user}/rtf-install-scripts/scripts/init.sh /opt/anypoint/runtimefabric/init.sh && chmod +x /opt/anypoint/runtimefabric/init.sh
      cat > /opt/anypoint/runtimefabric/env <<EOF 
        RTF_PRIVATE_IP=10.0.0.5 
        RTF_NODE_ROLE=controller_node 
        RTF_INSTALL_ROLE=leader 
        RTF_INSTALL_PACKAGE_URL= 
        RTF_ETCD_DEVICE=/dev/sdc 
        RTF_DOCKER_DEVICE=/dev/sdb 
        RTF_TOKEN='my-cluster-token' 
        RTF_NAME='runtime-fabric' 
        RTF_ACTIVATION_DATA='${var.rtf_activation_data}' 
        RTF_MULE_LICENSE='${var.rtf_mule_license}' 
        RTF_HTTP_PROXY='' 
        RTF_NO_PROXY='' 
        RTF_MONITORING_PROXY='' 
        RTF_SERVICE_UID='' 
        RTF_SERVICE_GID='' 
        POD_NETWORK_CIDR='10.244.0.0/16' 
        SERVICE_CIDR='10.100.0.0/16'
    SCRIPT
}

resource "google_compute_instance" "rtf-worker1" {
  attached_disk {
    mode        = "READ_WRITE"
    source      = google_compute_disk.rtf-worker1-docker.self_link
  }

  boot_disk {
    auto_delete = "true"
    device_name = "rtf-worker1-${var.postfix}"

    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/rhel-cloud/global/images/rhel-7-v20200521"
      size  = "80"
      type  = "pd-standard"
    }

    mode   = "READ_WRITE"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"
  machine_type        = "custom-2-15360-ext"
  name                = "rtf-worker1-${var.postfix}"

  network_interface {
    network            = google_compute_network.rtf-vpc.self_link
    network_ip         = "10.0.0.8"
    subnetwork         = google_compute_subnetwork.rtf-subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["rtf-allow-install", "rtf-allow-egress", "rtf-allow-internal", "rtf-allow-ssh", "rtf-allow-https"]
  zone = var.zone[1]

  metadata_startup_script = <<SCRIPT
      yum install zip unzip -y
      sudo -u ${var.gcp_user} curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/scripts/latest --output /home/${var.gcp_user}/rtf-install-scripts.zip
      sudo -u ${var.gcp_user} mkdir -p /home/${var.gcp_user}/rtf-install-scripts && unzip /home/${var.gcp_user}/rtf-install-scripts.zip -d /home/${var.gcp_user}/rtf-install-scripts
      chown ${var.gcp_user}:${var.gcp_user} -R /home/${var.gcp_user}/rtf-install-scripts
      mkdir -p /opt/anypoint/runtimefabric
      chown ${var.gcp_user}:${var.gcp_user} /opt/anypoint/runtimefabric
      sudo -u ${var.gcp_user} cp /home/${var.gcp_user}/rtf-install-scripts/scripts/init.sh /opt/anypoint/runtimefabric/init.sh && chmod +x /opt/anypoint/runtimefabric/init.sh
      cat > /opt/anypoint/runtimefabric/env <<EOF 
        RTF_PRIVATE_IP=10.0.0.8 
        RTF_NODE_ROLE=worker_node 
        RTF_INSTALL_ROLE=joiner 
        RTF_DOCKER_DEVICE=/dev/sdb 
        RTF_TOKEN='my-cluster-token' 
        RTF_INSTALLER_IP=10.0.0.5 
        RTF_HTTP_PROXY='' 
        RTF_NO_PROXY='' 
        RTF_MONITORING_PROXY='' 
        RTF_SERVICE_UID='' 
        RTF_SERVICE_GID=''
    SCRIPT
}

resource "google_compute_instance" "rtf-worker2" {
  attached_disk {
    mode        = "READ_WRITE"
    source      = google_compute_disk.rtf-worker2-docker.self_link
  }

  boot_disk {
    auto_delete = "true"
    device_name = "rtf-worker2-${var.postfix}"

    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/rhel-cloud/global/images/rhel-7-v20200521"
      size  = "80"
      type  = "pd-standard"
    }

    mode   = "READ_WRITE"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"
  machine_type        = "custom-2-15360-ext"
  name                = "rtf-worker2-${var.postfix}"

  network_interface {
    network            = google_compute_network.rtf-vpc.self_link
    network_ip         = "10.0.0.9"
    subnetwork         = google_compute_subnetwork.rtf-subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["rtf-allow-install", "rtf-allow-egress", "rtf-allow-internal", "rtf-allow-ssh", "rtf-allow-https"]
  zone = var.zone[2]

  metadata_startup_script = <<SCRIPT
      yum install zip unzip -y
      sudo -u ${var.gcp_user} curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/scripts/latest --output /home/${var.gcp_user}/rtf-install-scripts.zip
      sudo -u ${var.gcp_user} mkdir -p /home/${var.gcp_user}/rtf-install-scripts && unzip /home/${var.gcp_user}/rtf-install-scripts.zip -d /home/${var.gcp_user}/rtf-install-scripts
      chown ${var.gcp_user}:${var.gcp_user} -R /home/${var.gcp_user}/rtf-install-scripts
      mkdir -p /opt/anypoint/runtimefabric
      chown ${var.gcp_user}:${var.gcp_user} /opt/anypoint/runtimefabric
      sudo -u ${var.gcp_user} cp /home/${var.gcp_user}/rtf-install-scripts/scripts/init.sh /opt/anypoint/runtimefabric/init.sh && chmod +x /opt/anypoint/runtimefabric/init.sh
      cat > /opt/anypoint/runtimefabric/env <<EOF 
        RTF_PRIVATE_IP=10.0.0.9 
        RTF_NODE_ROLE=worker_node 
        RTF_INSTALL_ROLE=joiner 
        RTF_DOCKER_DEVICE=/dev/sdb 
        RTF_TOKEN='my-cluster-token' 
        RTF_INSTALLER_IP=10.0.0.5 
        RTF_HTTP_PROXY='' 
        RTF_NO_PROXY='' 
        RTF_MONITORING_PROXY='' 
        RTF_SERVICE_UID='' 
        RTF_SERVICE_GID=''
    SCRIPT
}