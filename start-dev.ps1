# FitGo dev environment launcher
# Starts backend and Flutter app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "      🚀 FitGo dev environment start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
$backendDir = Join-Path $projectRoot "backend"
$flutterDir = Join-Path $projectRoot "flutter"

# 1) Check if backend is already running
Write-Host "📋 Checking backend service..." -ForegroundColor Yellow
$backendRunning = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*FitGo\backend*" }

if ($backendRunning) {
    Write-Host "   ⚠️  Backend already running (PID: $($backendRunning.Id))" -ForegroundColor Yellow
    $response = Read-Host "   Restart backend? (y/n)"
    if ($response -eq 'y') {
        Write-Host "   ⏳ Stopping old process..." -ForegroundColor Cyan
        $backendRunning | Stop-Process -Force
        Start-Sleep -Seconds 2
    } else {
        Write-Host "   ✅ Using existing backend process" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Skip backend start, launch Flutter..." -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Set-Location $flutterDir
        flutter run
        exit
    }
}

# 2) Start backend
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "1) Start backend server" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$backendJob = Start-Job -ScriptBlock {
    param($backendPath)
    Set-Location $backendPath
    node server.js
} -ArgumentList $backendDir

Write-Host "✅ Backend started in background (Job ID: $($backendJob.Id))" -ForegroundColor Green
Write-Host "   Waiting for backend to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# 检查后端是否成功启动
$backendProcess = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*node.exe*" } | Select-Object -First 1
if ($backendProcess) {
    Write-Host "   ✅ Backend running (PID: $($backendProcess.Id))" -ForegroundColor Green
    Write-Host "   📡 API: http://localhost:3000" -ForegroundColor Cyan
} else {
    Write-Host "   ⚠️  Backend may have failed to start; check logs" -ForegroundColor Yellow
}

# 3) Start Flutter
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "2) Start Flutter app" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Set-Location $flutterDir

Write-Host "Tip: Ctrl+C to stop Flutter; backend keeps running" -ForegroundColor Yellow
Write-Host "      To stop backend: Get-Process node | Stop-Process -Force" -ForegroundColor Yellow
Write-Host ""

# 启动 Flutter（前台运行）
flutter run

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter app exited" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend is still running." -ForegroundColor Yellow
Write-Host "To stop backend: Get-Process node | Stop-Process -Force" -ForegroundColor Yellow
