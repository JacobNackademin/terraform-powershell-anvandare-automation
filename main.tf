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

# Aktiverar local providern
# Används för att skapa och hantera lokala filer.
provider "local" {}


#VARIABLER
#Ange vilka användare som ska skapas i denna lista

variable "users" {
  type = list(string)

  default = [
    "anvandare01",
    "anvandare02",
    "anvandare03"
  ]
}