# Terraform PowerShell Användare Automation

## Mål
Målet med detta projekt är att enkelt kunna skapa flera användare samtidigt på en miljö med användning av PowerShell och Terraform.

## Metod
Terraform skapar users.json och projekt.info.txt som PowerShell i sin tur läser JSON filen och hanterar användarna som sedan skapas på Linux miljön och till sist så kontrollerar och verifierar Terraform användarna.

## Resultat
Resultatet blir att nya användare skapas på miljön smidigt med verifiering och eftersom det är idempontent finns det ingen risk att om man råkar köra skriptet två eller flera gånger så kan inte samma användare skapas igen.

## Reflektion
I helhet gick detta projekt bra, men det var lite knepigt att lista ut hur man ska få ihop koden i PowerShell för att det skulle fungera, även fast det är rätt så simpelt. Terraform var väldigt bekvämt för det är lätt att använda och jag behövde inte skriva jätte mycket kod. Jag använde VSCode när jag skrev all kod och kunde ta hjälp av VSCodes AI agent när jag körde fast.


## GitHub Repository
https://github.com/JacobNackademin/terraform-powershell-anvandare-automation