#Terraform-konfiguration
#Anger vilka providers projektet behöver.



terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}