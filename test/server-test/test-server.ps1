# Automated Test Script for Server Start/Stop Functionality
# Tests the isolated test environment (ports 8001, 3001)

$ErrorActionPreference = "Continue"
$testsPassed = 0
$testsFailed = 0

function Write-TestResult {
    param([bool]$Pass, [string]$Message)
    if ($Pass) {
        Write-Host "  [PASS] $Message" -ForegroundColor Green
        $script:testsPassed++
    } else {
        Write-Host "  [FAIL] $Message" -ForegroundColor Red
        $script:testsFailed++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Trader Jarvis Server Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Initial Cleanup
Write-Host "[1/5] Initial Cleanup" -ForegroundColor Yellow
& "$PSScriptRoot\stop-test.ps1" | Out-Null
Start-Sleep -Seconds 2

$port8001 = Get-NetTCPConnection -LocalPort 8001 -State Listen -ErrorAction SilentlyContinue
$port3001 = Get-NetTCPConnection -LocalPort 3001 -State Listen -ErrorAction SilentlyContinue
Write-TestResult -Pass ($null -eq $port8001) -Message "Port 8001 is free"
Write-TestResult -Pass ($null -eq $port3001) -Message "Port 3001 is free"
Write-Host ""

# Test 2: Start Test Servers
Write-Host "[2/5] Starting Test Servers" -ForegroundColor Yellow
& "$PSScriptRoot\start-test.ps1" | Out-Null
Write-Host "  Waiting 10 seconds for servers to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 10

$port8001 = Get-NetTCPConnection -LocalPort 8001 -State Listen -ErrorAction SilentlyContinue
$port3001 = Get-NetTCPConnection -LocalPort 3001 -State Listen -ErrorAction SilentlyContinue
Write-TestResult -Pass ($null -ne $port8001) -Message "Backend listening on port 8001"
Write-TestResult -Pass ($null -ne $port3001) -Message "Frontend listening on port 3001"
Write-Host ""

# Test 3: Health Checks
Write-Host "[3/5] Testing HTTP Endpoints" -ForegroundColor Yellow

# Test backend health endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8001/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-TestResult -Pass ($response.StatusCode -eq 200) -Message "Backend /health endpoint responds (HTTP $($response.StatusCode))"
} catch {
    Write-TestResult -Pass $false -Message "Backend /health endpoint failed: $($_.Exception.Message)"
}

# Test backend root endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8001/" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-TestResult -Pass ($response.StatusCode -eq 200) -Message "Backend root endpoint responds (HTTP $($response.StatusCode))"
} catch {
    Write-TestResult -Pass $false -Message "Backend root endpoint failed: $($_.Exception.Message)"
}

# Test frontend endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-TestResult -Pass ($response.StatusCode -eq 200) -Message "Frontend responds (HTTP $($response.StatusCode))"
} catch {
    Write-TestResult -Pass $false -Message "Frontend failed: $($_.Exception.Message)"
}
Write-Host ""

# Test 4: Verify Dev Servers Unaffected
Write-Host "[4/5] Verify Dev Servers Unaffected" -ForegroundColor Yellow
$devBackend = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
$devFrontend = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue

if ($devBackend -or $devFrontend) {
    Write-TestResult -Pass ($null -ne $devBackend) -Message "Dev backend still running on 8000"
    Write-TestResult -Pass ($null -ne $devFrontend) -Message "Dev frontend still running on 3000"
} else {
    Write-Host "  [INFO] No dev servers running (expected if not started)" -ForegroundColor Gray
}
Write-Host ""

# Test 5: Stop Test Servers
Write-Host "[5/5] Stopping Test Servers" -ForegroundColor Yellow
& "$PSScriptRoot\stop-test.ps1" | Out-Null
Start-Sleep -Seconds 3

$port8001 = Get-NetTCPConnection -LocalPort 8001 -State Listen -ErrorAction SilentlyContinue
$port3001 = Get-NetTCPConnection -LocalPort 3001 -State Listen -ErrorAction SilentlyContinue
Write-TestResult -Pass ($null -eq $port8001) -Message "Port 8001 released"
Write-TestResult -Pass ($null -eq $port3001) -Message "Port 3001 released"
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "  Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "  Total Tests:  $($testsPassed + $testsFailed)" -ForegroundColor White
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "  All Tests PASSED!" -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "  Some Tests FAILED" -ForegroundColor Red
    Write-Host ""
    exit 1
}
