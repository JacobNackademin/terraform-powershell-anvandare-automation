param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath
)


#USER AUTOMATION PROJECT
#PowerShell - Skapa och verifiera Linux-användare
#Miljö: Ubuntu via WSL


#Gör så att PowerShell stoppar vid allvarliga fel
$ErrorActionPreference = "Stop"

#Hämta sökvagen till loggfilen
$LogPath = Join-Path $PSScriptRoot "user-creation.log"


#FUNKTION 1: LOGGNING
#Skriver meddelanden till både terminal och loggfil


function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $LogMessage = "[$Timestamp] [$Level] $Message"

    Write-Host $LogMessage

    Add-Content -Path $LogPath -Value $LogMessage
}


#FUNKTION 2: LÄSA KONFIGURATION
#Läser användarnamnen från Terraform-genererad JSON


function Get-UserConfig {
    param(
        [string]$ConfigPath
    )

    try {
        #Kontrollera att konfigurationsfilen finns
        if (-not (Test-Path -Path $ConfigPath)) {
            throw "Konfigurationsfilen kunde inte hittas: $ConfigPath"
        }

        #Läs filens innehåll och omvandla JSON till objekt
        $Config = Get-Content -Path $ConfigPath -Raw |
            ConvertFrom-Json

        #Kontrollera att det finns en användarlista
        if (-not $Config.users -or $Config.users.Count -eq 0) {
            throw "Ingen användarlista hittades i JSON-filen."
        }

        Write-Log "Konfigurationen läste in korrekt."

        return $Config.users
    }
    catch {
        Write-Log "Fel vid inläsning av konfiguration: $_" "ERROR"
        throw
    }
}


#FUNKTION 3: KONTROLLERA ANVÄNDARE
#Använder Linux-kommandot getent för att kontrollera om ett användarkonto redan existerar


function Test-LocalUser {
    param(
        [string]$Username
    )

    #getent passwd returnerar information om användaren
    #om kontot finns i systemets användardatabas.
    & getent passwd $Username *> $null

    return ($LASTEXITCODE -eq 0)
}


#FUNKTION 4: SKAPA ANVÄNDARE
#Skapar ett Linux-konto med useradd om det saknas


function New-LocalUser {
    param(
        [string]$Username
    )

    #Kontrollera att användarnamnet har tillåtet format
    if ($Username -notmatch '^[a-z_][a-z0-9_-]{0,31}$') {
        throw "Ogiltigt användarnamn: $Username"
    }

    #Kontrollera om användaren redan finns
    if (Test-LocalUser -Username $Username) {
        Write-Log "Användaren $Username finns redan. Hoppar över."
        return
    }

    Write-Log "Försöker skapa användaren $Username."

    #Skapa användaren och en egen hemkatalog.
    #sudo ger behörighet att skapa Linux-användare.
    $Result = & sudo useradd -m -- $Username 2>&1

    #Kontrollera om Linux-kommandot lyckades.
    if ($LASTEXITCODE -ne 0) {
        throw "Kunde inte skapa $Username. $Result"
    }

    Write-Log "Användaren $Username skapades."
}



#FUNKTION 5: VERIFIERING
#Kontrollerar att alla användare verkligen finns.


function Test-Users {
    param(
        [string[]]$Users
    )

    $SuccessfulUsers = 0
    $FailedUsers = 0

    #Loopar igenom samtliga användare i listan
    foreach ($Username in $Users) {

        #Kontrollera om användaren finns
        if (Test-LocalUser -Username $Username) {

            Write-Log "VERIFIERAD: $Username finns i systemet."
            $SuccessfulUsers++

        }
        else {

            Write-Log "FEL: $Username kunde inte verifieras." "ERROR"
            $FailedUsers++

        }
    }

    #Visa sammanfattning av verifieringen
    Write-Log "Verifiering klar. Godkanda: $SuccessfulUsers. Misslyckade: $FailedUsers."

    #Avbryt med felstatus om någon användare saknas
    if ($FailedUsers -gt 0) {
        throw "En eller flera användare kunde inte verifieras."
    }
}



#HUVUDPROGRAM
#Här startar hela PowerShell-processen.


try {

    Write-Log "======================================"
    Write-Log "USER AUTOMATION STARTAR"
    Write-Log "======================================"

    #Kontrollera sudo-behörighet innan användare skapas
    Write-Log "Kontrollerar sudo-behörighet."

    & sudo -v

    if ($LASTEXITCODE -ne 0) {
        throw "Sudo-behörighet kunge inte bekräftas."
    }

    #Hämta användarna fran Terraform-konfigurationen
    $Users = Get-UserConfig -ConfigPath $ConfigPath

    #Loopar igenom listan och skapar saknade användare
    foreach ($Username in $Users) {
        New-LocalUser -Username $Username
    }

    #Verifiera att samtliga användare finns
    Test-Users -Users $Users

    Write-Log "USER AUTOMATION SLUTFÖRDES UTAN KRITISKA FEL."
}
catch {

    #Fångar fel som uppstår inom körningen
    Write-Log "PROJEKTET AVBRÖTS: $_" "ERROR"

    exit 1
}
