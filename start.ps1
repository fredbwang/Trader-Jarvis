# Trader Jarvis - Start Script
# This script starts both the backend and frontend servers

Write-Host "Starting Trader Jarvis..." -ForegroundColor Cyan
Write-Host ""

# Check if backend directory exists
if (-Not (Test-Path "backend")) {
    Write-Host "Error: backend directory not found!" -ForegroundColor Red
    exit 1
}

# Check if frontend directory exists
if (-Not (Test-Path "frontend")) {
    Write-Host "Error: frontend directory not found!" -ForegroundColor Red
    exit 1
}

# Start Backend Server
Write-Host "Starting Backend Server (FastAPI)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\backend'; Write-Host 'Trader Jarvis Backend Starting...' -ForegroundColor Green; python trader-jarvis-backend.py"

# Wait a moment for backend to initialize
Start-Sleep -Seconds 2

# Start Frontend Server
Write-Host "Starting Frontend Server (Next.js)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\frontend'; Write-Host 'Trader Jarvis Frontend Starting...' -ForegroundColor Green; npm run dev:jarvis"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Trader Jarvis is starting up!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend:  http://localhost:8000" -ForegroundColor Yellow
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "API Docs: http://localhost:8000/docs" -ForegroundColor Gray
Write-Host ""
Write-Host "Two new PowerShell windows have opened." -ForegroundColor Gray
Write-Host "Close those windows to stop the servers." -ForegroundColor Gray
Write-Host ""
