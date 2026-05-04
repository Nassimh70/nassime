# Script pour compiler les dépendances bcrypt via Docker
# Assurez-vous que Docker Desktop est installé et en cours d'exécution

$projectPath = "C:\Users\DELL\Desktop\PFC\StudentVoiceApp"
$backendPath = "$projectPath\backend"

Write-Host "Vérification de Docker..." -ForegroundColor Cyan
$dockerCheck = docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker n'est pas installé ou ne fonctionne pas" -ForegroundColor Red
    Write-Host "Veuillez installer Docker Desktop depuis https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Docker est disponible: $dockerCheck" -ForegroundColor Green

Write-Host "`nConstruction de l'image Docker..." -ForegroundColor Cyan
docker build -t studentvoice-builder -f "$backendPath\Dockerfile" --target builder "$backendPath"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Échec de la construction de l'image Docker" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Image construite avec succès" -ForegroundColor Green

Write-Host "`nExport des dépendances compilées..." -ForegroundColor Cyan
# Créer un conteneur temporaire et copier les fichiers compilés
docker create --name studentvoice-temp studentvoice-builder | Out-Null
docker cp studentvoice-temp:/app/deps "$backendPath"
docker cp studentvoice-temp:/app/_build "$backendPath"
docker rm studentvoice-temp | Out-Null

Write-Host "`n✓ Dépendances compilées avec succès!" -ForegroundColor Green
Write-Host "`nVous pouvez maintenant utiliser 'mix' directement sur Windows" -ForegroundColor Yellow
