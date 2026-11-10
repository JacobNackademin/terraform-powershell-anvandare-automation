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


#Projektinformation
#Skapar en textfil med grundläggande Projektinformation
#Ger en ytterligare resurs till terraforms användning

resource "local_file" "project_manifest" {
  filename = "${path.module}/project-info.txt"

  content = <<-EOT
    Project: User Automation
    Tool: Terraform and PowerShell
    Environment: Ubuntu WSL
  EOT
}


#Användning av PowerShell
#terraform_data används för att starta PowerShell
#depends_on säkerställer att konfigurationsfilerna skapas innan PowerShell-skriptet körs

resource "terraform_data" "run_powershell" {

  depends_on = [
    local_file.user_config,
    local_file.project_manifest
  ]

  # Kör om resursen om användarkonfigurationen
  # eller PowerShell-skriptet har ändrats
  
  triggers_replace = [
    local_file.user_config.content,
    filesha256("${path.module}/verify.ps1")
  ]

  # Startar PowerShell och skickar sökvägen
  # till JSON-filen som en parameter
  
  provisioner "local-exec" {
    command = "pwsh -NoProfile -File \"${path.module}/verify.ps1\" -ConfigPath \"${local_file.user_config.filename}\""
  }
}


#Outputs
#Visar information efter terraform körts

# Visar vilka användare som finns i konfigurationen.
output "configured_users" {
  description = "Användare som ska hanteras av projektet"
  value       = var.users
}

# Visar sökvägen till JSON-konfigurationen.
output "configuration_file" {
  description = "Sökväg till användarkonfigurationen"
  value       = local_file.user_config.filename
}