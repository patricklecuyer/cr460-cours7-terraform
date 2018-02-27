resource "google_compute_instance" "instance1" {
  name         = "instance1"                 # Nom
  machine_type = "n1-standard-1"             # Taille de la machine
  zone         = "northamerica-northeast1-a" # Zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8" # Disque
    }
  }

  metadata_startup_script = "sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install apache2 && sudo systemctl start apache2"

  network_interface {
    subnetwork    = "${google_compute_subnetwork.cr460-subnet1.self_link}" # Interface Reseau
    access_config = {}
  }

  tags = ["web", "patate", "cr460", "linux"]
}

#Definition du sous-reseau
resource "google_compute_subnetwork" "cr460-subnet1" {
  name          = "cr460-subnet1"                             # Nom
  ip_cidr_range = "10.0.0.0/24"                               # Adresse IP
  network       = "${google_compute_network.cr460.self_link}" # Liens vers le reseau
  region        = "northamerica-northeast1"                   # Region
}

# Definition du VPC
resource "google_compute_network" "cr460" {
  name                    = "cr460" # Nom du reseau
  auto_create_subnetworks = "false"
}

resource "google_compute_firewall" "http" {
  name    = "http"
  network = "${google_compute_network.cr460.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["web"]
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = "${google_compute_network.cr460.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["linux"]
}

# Definir le fournisseur nuagique
provider "google" {
  credentials = "${file("account.json")}"
  project     = "cr460-cours6"
  region      = "northamerica-northeast1"
}
