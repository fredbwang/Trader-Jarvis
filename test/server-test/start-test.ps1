# Start Test Servers on different ports (8001, 3001)
# This allows running tests without interfering with dev servers

Write-Host "Starting Trader Jarvis TEST Environment..." -ForegroundColor Cyan
Write-Host ""

# Start Backend Server (Test - Port 8001)
Write-Host "Starting Backend Server (Test - Port 8001)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", @"
cd '$PSScriptRoot\..\..\backend'
Write-Host 'Trader Jarvis Backend (TEST) Starting...' -ForegroundColor Green
`$env:ENV_FILE='.env.test'
python trader-jarvis-backend.py
"@

# Wait for backend
Start-Sleep -Seconds 2

# Start Frontend Server (Test - Port 3001)
Write-Host "Starting Frontend Server (Test - Port 3001)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", @"
cd '$PSScriptRoot\..\..\frontend'
Write-Host 'Trader Jarvis Frontend (TEST) Starting...' -ForegroundColor Green
`$env:PORT=3001
npm run dev
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Trader Jarvis TEST Environment Starting" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend (TEST):  http://localhost:8001" -ForegroundColor Yellow
Write-Host "Frontend (TEST): http://localhost:3001" -ForegroundColor Yellow
Write-Host ""
Write-Host "Dev servers (8000, 3000) are unaffected" -ForegroundColor Gray
Write-Host ""
