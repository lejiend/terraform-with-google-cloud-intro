terraform {
    required_version = ">= 1.0"
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 5.0"
        }
    }
    
}


provider "google" {
    project = "my-free-learning-tutorial"
    region = "asia-southeast1"
    zone = "asia-southeast1-a"
}


