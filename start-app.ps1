#!/usr/bin/env pwsh
# FitGo Application Startup Script
# Auto-start backend and initialize database

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    FitGo Application Setup & Start    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
Write-Host "1) Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = & node --version
    Write-Host "   ✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Node.js not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Please install Node.js first:" 
    Write-Host "   1. Visit https://nodejs.org (LTS)" -ForegroundColor Cyan
    Write-Host "   2. Download and install"
    Write-Host "   3. Restart PowerShell"
    Write-Host ""
    exit 1
}

# Check npm
Write-Host ""
Write-Host "2) Checking npm..." -ForegroundColor Yellow
try {
    $npmVersion = & npm --version
    Write-Host "   ✅ npm found: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ npm not installed!" -ForegroundColor Red
    exit 1
}

# Check MySQL
Write-Host ""
Write-Host "3) Checking MySQL..." -ForegroundColor Yellow
try {
    $mysqlVersion = & mysql --version
    Write-Host "   ✅ MySQL found: $mysqlVersion" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  MySQL command not found; ensure it is installed" -ForegroundColor Yellow
    Write-Host "   Hint: add MySQL bin to PATH" -ForegroundColor Yellow
}

# Enter project directories
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $projectRoot "backend"
$flutterDir = Join-Path $projectRoot "flutter"

Write-Host ""
Write-Host "4) Enter backend directory..." -ForegroundColor Yellow
Set-Location $backendDir
Write-Host "   📂 Current directory: $(Get-Location)" -ForegroundColor Green

# Check .env file
Write-Host ""
Write-Host "5) Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "   ✅ .env file exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ .env file is missing!" -ForegroundColor Red
    exit 1
}

# Check node_modules
Write-Host ""
Write-Host "6) Checking npm dependencies..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Write-Host "   ✅ Dependencies already installed" -ForegroundColor Green
} else {
    Write-Host "   ⏳ Installing dependencies..." -ForegroundColor Cyan
    & npm install
    Write-Host "   ✅ Dependencies installed" -ForegroundColor Green
}

# Initialize database
Write-Host ""
Write-Host "7) Initializing database..." -ForegroundColor Yellow
try {
    $mysqlInstalled = $true
    $mysqlCmd = & mysql --version 2>$null
} catch {
    $mysqlInstalled = $false
}

if ($mysqlInstalled) {
    Write-Host "   ⏳ Creating database and tables..." -ForegroundColor Cyan
    try {
        & mysql -u root -proot < init_database.sql
        Write-Host "   ✅ Database initialized" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Database init may have failed; run manually:" -ForegroundColor Yellow
        Write-Host "      mysql -u root -proot < backend/init_database.sql" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ℹ️  Please initialize DB manually:" -ForegroundColor Yellow
    Write-Host "      mysql -u root -proot < backend/init_database.sql" -ForegroundColor Yellow
}

# Start backend service
Write-Host ""
Write-Host "8) Start FitGo backend..." -ForegroundColor Yellow
Write-Host "   🚀 Command: npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Backend info:" -ForegroundColor Yellow
Write-Host "   - URL: http://localhost:3000" -ForegroundColor Gray
Write-Host "   - Health: http://localhost:3000/health" -ForegroundColor Gray
Write-Host "   - Stop: Ctrl + C" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Launch Flutter app in another terminal:" -ForegroundColor Yellow
Write-Host "  cd $flutterDir" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Start dev server
& npm run dev
