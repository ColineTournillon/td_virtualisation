/*terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.12.0"
    }
  }
}
*/

provider "google" {
  project = "esirem"
  region  = "europe-west1"
  zone = "europe-west1-b"
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

resource "google_compute_subnetwork""vpc_subnetwork"{
  name= "vpc-subnetwork"
  ip_cidr_range = "192.168.1.0/24"
  network = google_compute_network.vpc_network.name
}



resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"

}

resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "n2-standard-2"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_subnetwork.vpc_subnetwork.name
    access_config{
      nat_ip="192.168.1.1"
    }
  
  }
}

resource "google_sql_database_instance" "database" {
  name             = "database-instance"
  database_version = "POSTGRES_15"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}

resource "google_dns_managed_zone" "dns_zone" {
  name ="kiowy.com"
  dns_name = "kiowy.com."
}

resource "google_dns_record_set" "dns_set" {
  name = "dns_set.${google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.dns_zone.name
  rrdatas = [google_compute_instance.webserver.network_interface[0].access_config[0].nat_ip]
}