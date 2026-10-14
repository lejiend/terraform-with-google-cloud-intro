resource "google_compute_instance" "vm_instance" {
    name = "my-automation-instance"
    machine_type = "e2-small"
    zone = "asia-southeast1-a"


    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
        }
    }

    tags = ["application-server"]

    metadata = {

       "ssh-keys" = "lejiend:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK35EvNPWI9R+3MugOyIUZJ0ZD8NYYsJwFTjcmfPRgeC" 
    
        "startup-script" = <<-EOF
            #! /bin/bash
            apt-get update
            apt-get install -y nginx
            systemctl start nginx
            systemctl enable nginxx
        EOF
    }

    network_interface {
        network = "default"

        access_config {}
    }

}

output "instance_public_ip" {
    value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}


resource "google_compute_firewall" "allow_http_ssh" {
    name = "allow-http-ssh"
    network = "default"


    allow {
        protocol = "tcp"
        ports = [ "22", "80"]
    }

    target_tags = ["application-server"]

    source_ranges = ["0.0.0.0/0"]
}