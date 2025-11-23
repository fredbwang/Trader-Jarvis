# Stop Test Servers (ports 8001, 3001 only)
# Leaves dev servers (8000, 3000) running

Write-Host "Stopping Trader Jarvis TEST Environment..." -ForegroundColor Cyan
Write-Host ""

$stoppedAny = $false

# Stop processes on TEST ports only
Write-Host "Looking for processes on test ports 8001 and 3001..." -ForegroundColor Yellow

$portProcesses = @()

# Get processes using port 8001 (test backend)
$testBackend = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Listen' } |
    Select-Object -ExpandProperty OwningProcess -Unique

if ($testBackend) {
    foreach ($processId in $testBackend) {
        if ($processId -gt 0) {
            $portProcesses += $processId
        }
    }
}

# Get processes using port 3001 (test frontend)
$testFrontend = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Listen' } |
    Select-Object -ExpandProperty OwningProcess -Unique

if ($testFrontend) {
    foreach ($processId in $testFrontend) {
        if ($processId -gt 0) {
            $portProcesses += $processId
        }
    }
}

# Remove duplicates
$portProcesses = $portProcesses | Select-Object -Unique

if ($portProcesses) {
    $count = ($portProcesses | Measure-Object).Count
    Write-Host "Found $count test process(es). Stopping..." -ForegroundColor Green
    foreach ($processId in $portProcesses) {
        try {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  Stopping $($process.Name) (PID: $processId)" -ForegroundColor Gray

                # If it's a PowerShell process, also stop its children
                if ($process.Name -like "powershell*") {
                    $children = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $processId }
                    foreach ($child in $children) {
                        Write-Host "    Stopping child: $($child.Name) (PID: $($child.ProcessId))" -ForegroundColor DarkGray
                        Stop-Process -Id $child.ProcessId -Force -ErrorAction SilentlyContinue
                    }
                }

                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                $stoppedAny = $true
            }
        } catch {
            Write-Host "  Failed to stop PID: $processId" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  No test processes found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($stoppedAny) {
    Write-Host "Test environment stopped!" -ForegroundColor Green
} else {
    Write-Host "No test servers were running" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dev servers (8000, 3000) are unaffected" -ForegroundColor Gray
Write-Host ""
