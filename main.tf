#Terraform-konfiguration
#Anger vilka providers projektet behöver


terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}


# Aktiverar local providern
# Används för att skapa och hantera lokala filer
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


#Användarkonfiguration
#Skapar en JSON-fil med användarnamnen
#Powershell kommer använda sig av denna fil

resource "local_file" "user_config" {
  filename = "${path.module}/users.json"

  # jsonencode omvandlar vår lista till JSON-format.
  content = jsonencode({
    users = var.users
  })
}