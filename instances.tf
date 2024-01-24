# External IP addresses
resource "google_compute_address" "ip-address" {
  count = var.nodes
  name  = "ip-address-${count.index}"
  # subnetwork = google_compute_subnetwork.subnet.id
  region = var.gcp_region
}

# Create firewall rules
resource "google_compute_firewall" "default" {
  name    = "hashi-rules"
  network = google_compute_network.network.name

  # We are opening some ports related to Vault and Consul for testing purposes
  allow {
    protocol = "tcp"
    ports    = [
      "22",
      "443",
      "8443",
      "8200", 
      "8250",
      "8501",
      "8300",
      "8301",
      "8302",
      "8502",
      "8503",
      "21000"
    ]
  }
  allow {
    protocol = "udp"
    ports    = [
      "8300",
      "8301",
      "8302",
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.owner}"]
}

resource "google_compute_firewall" "internal" {
  name    = "hashi-rules-internal"
  network = google_compute_network.network.name

  # We allow all traffic inside the network
  allow {
    protocol = "tcp"
    ports    = []
  }
  allow {
    protocol = "udp"
    ports    = []
  }

  source_tags = ["${var.owner}"]
  target_tags   = ["${var.owner}"]
}


## ------ Compute instances ---------
# Define image to use for VMs
data "google_compute_image" "my_image" {
  family  = "debian-12"
  project = "debian-cloud"
}

# Create an instance template to use for similar VMs (but this template is not really used for VM creation)
resource "google_compute_instance_template" "instance-template" {
  name_prefix  = "instance-template-"
  machine_type = var.machine

  //boot disk
  disk {
    source_image = data.google_compute_image.my_image.self_link
  }

  network_interface {
    network = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.network_subnet1.self_link
    access_config {

    }
  }
}


resource "google_compute_instance" "vm" {
  count        = var.nodes
  name         = "vm-client-${count.index}"
  machine_type = var.machine
  zone         = var.gcp_zone

  tags = [var.owner]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      size  = 50
      type  = "pd-ssd"
    }
  }

  #   // Local SSD disk
  #   scratch_disk {
  #     interface = "SCSI"
  #   }

  network_interface {
    network = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.network_subnet1.self_link
    access_config {
      nat_ip = google_compute_address.ip-address[count.index].address
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  labels = {
    node  = "my_node_-${count.index}"
    owner = var.owner
  }
}


