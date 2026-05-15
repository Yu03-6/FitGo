# FitGo backend start script (Windows PowerShell)

$backendPath = Join-Path $PSScriptRoot "backend"
Push-Location $backendPath

Write-Host "=========================================="
Write-Host "🚀 FitGo backend start" -ForegroundColor Green
Write-Host "=========================================="
Write-Host ""

# Check dependencies
Write-Host "1) Checking npm dependencies..." -ForegroundColor Cyan
if (-not (Test-Path "node_modules")) {
  Write-Host "   ⚠️  node_modules missing, installing..." -ForegroundColor Yellow
  & npm install
} else {
  Write-Host "   ✅ Dependencies already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "2) Starting backend..." -ForegroundColor Cyan
Write-Host "   📍 Service: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   📊 MySQL database: fitgo" -ForegroundColor Cyan
Write-Host ""
Write-Host "=========================================="
Write-Host ""

# Start backend
& npm start

Pop-Location
