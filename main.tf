terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("/home/arseniizakharov1/service-account.json.json")
  project = "terraform3ta"
  region  = "europe-west1"
  zone    = "europe-west1-c"
}

resource "google_compute_network" "vpc_zakharov" {
  name                    = "vpc-network"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnetwork-1" {
  name                    = "zakharov-private-1"
  ip_cidr_range           = "10.0.1.0/24"
  network                 = "vpc_zakharov"
}

resource "google_compute_subnetwork" "subnetwork-2" {
  name                    = "zakharov-private-2"
  ip_cidr_range           = "10.0.2.0/24"
  network                 = "vpc_zakharov"
  private_ip_google_access = "true"
}

resource "google_compute_firewall" "firewall" {
  name          = "zakharov-firewall"
  network       = "vpc_zakharov"
  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
  priority      = "65534"

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "default-allow-icmp-three-tier" {
  name = "firewall-icmp"
  network = "vpc_zakharov"
  priority = "65534"
    allow {
      protocol = "icmp"
    }
}

resource "google_compute_firewall" "allow-lb-health" {
  name = "lb-health-check"
  network = "vpc_zakharov"
  priority = "65534"
  direction = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags = ["allow-healthcheck"]

    allow {
      protocol = "tcp"
      ports = ["80"]
    }
}

resource "google_compute_firewall" "allow-http" {
  name = "allow-http"
  network = "vpc_zakharov"
  direction = "INGRESS"
  target_tags = ["allow-http"]
    allow {
      protocol = "tcp"
      ports = ["80"]
    }
}

resource "google_compute_firewall" "allow-ssh-ingress-from-iap" {
  name = "allow-ssh-ingress-from-iap"
  network = "vpc_zakharov"
  direction = "INGRESS"
  target_tags = ["allow-ssh"]
  source_ranges = ["35.235.240.0/20"]
    allow {
      protocol = "tcp"
      ports = ["22"]
    }
}


