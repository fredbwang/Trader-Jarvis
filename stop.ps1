# Trader Jarvis - Stop Script
# This script gracefully stops both the backend and frontend servers

Write-Host "Stopping Trader Jarvis..." -ForegroundColor Cyan
Write-Host ""

$stoppedAny = $false

# First, try to stop by port number (most reliable method)
Write-Host "Looking for processes on ports 8000 and 3000..." -ForegroundColor Yellow

$portProcesses = @()

# Get processes using port 8000 (backend)
$backendPort = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Listen' } |
    Select-Object -ExpandProperty OwningProcess -Unique

if ($backendPort) {
    foreach ($processId in $backendPort) {
        if ($processId -gt 0) {
            $portProcesses += $processId
        }
    }
}

# Get processes using port 3000 (frontend)
$frontendPort = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Listen' } |
    Select-Object -ExpandProperty OwningProcess -Unique

if ($frontendPort) {
    foreach ($processId in $frontendPort) {
        if ($processId -gt 0) {
            $portProcesses += $processId
        }
    }
}

# Remove duplicates
$portProcesses = $portProcesses | Select-Object -Unique

if ($portProcesses) {
    $count = ($portProcesses | Measure-Object).Count
    Write-Host "Found $count process(es) on server ports. Stopping..." -ForegroundColor Green
    foreach ($processId in $portProcesses) {
        try {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  Stopping $($process.Name) (PID: $processId)" -ForegroundColor Gray

                # If it's a PowerShell process, also stop its child processes
                if ($process.Name -like "powershell*") {
                    # Get child processes
                    $children = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $processId }
                    foreach ($child in $children) {
                        Write-Host "    Stopping child process: $($child.Name) (PID: $($child.ProcessId))" -ForegroundColor DarkGray
                        Stop-Process -Id $child.ProcessId -Force -ErrorAction SilentlyContinue
                    }
                }

                # Stop the main process
                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                $stoppedAny = $true
            }
        } catch {
            Write-Host "  Failed to stop PID: $processId" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  No processes found on ports 8000 or 3000" -ForegroundColor Gray
}

Write-Host ""

# Stop Backend Server (Python/FastAPI)
Write-Host "Looking for Backend Server (Python)..." -ForegroundColor Yellow

# Look for Python processes running the backend
$backendProcesses = Get-Process python* -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*main.py*" -or
    $_.Path -like "*Trader-Jarvis\backend*" -or
    $_.CommandLine -like "*backend*main.py*"
}

# Also look for uvicorn processes (alternative backend runner)
$uvicornProcesses = Get-Process python* -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*uvicorn*" -and
    $_.CommandLine -like "*main:app*"
}

if ($uvicornProcesses) {
    $backendProcesses = @($backendProcesses) + @($uvicornProcesses)
}

if ($backendProcesses) {
    $count = ($backendProcesses | Measure-Object).Count
    Write-Host "Found $count backend process(es). Stopping..." -ForegroundColor Green
    $backendProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped process ID: $($_.Id)" -ForegroundColor Gray
    }
    $stoppedAny = $true
} else {
    Write-Host "  No backend server running" -ForegroundColor Gray
}

Write-Host ""

# Stop Frontend Server (Node.js/Next.js)
Write-Host "Looking for Frontend Server (Node.js)..." -ForegroundColor Yellow

# Look for Node.js processes running Next.js
$frontendProcesses = Get-Process node* -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*next dev*" -or
    $_.CommandLine -like "*next*dev*" -or
    $_.Path -like "*Trader-Jarvis\frontend*"
}

if ($frontendProcesses) {
    $count = ($frontendProcesses | Measure-Object).Count
    Write-Host "Found $count frontend process(es). Stopping..." -ForegroundColor Green
    $frontendProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped process ID: $($_.Id)" -ForegroundColor Gray
    }
    $stoppedAny = $true
} else {
    Write-Host "  No frontend server running" -ForegroundColor Gray
}

Write-Host ""

# Check for Bash/Shell processes running the servers
Write-Host "Checking for Bash/Shell processes..." -ForegroundColor Yellow
$shellProcesses = @()

# Look for bash processes
$bashProcesses = Get-Process bash* -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*python*main.py*" -or
    $_.CommandLine -like "*npm*run*dev*" -or
    $_.CommandLine -like "*backend*" -or
    $_.CommandLine -like "*frontend*"
}

if ($bashProcesses) {
    $shellProcesses += $bashProcesses
}

# Look for sh processes
$shProcesses = Get-Process sh* -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*python*main.py*" -or
    $_.CommandLine -like "*npm*run*dev*"
}

if ($shProcesses) {
    $shellProcesses += $shProcesses
}

if ($shellProcesses) {
    $count = ($shellProcesses | Measure-Object).Count
    Write-Host "Found $count shell process(es). Stopping..." -ForegroundColor Green
    $shellProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Stopped process ID: $($_.Id)" -ForegroundColor Gray
    }
    $stoppedAny = $true
} else {
    Write-Host "  No shell processes found" -ForegroundColor Gray
}

Write-Host ""

# Kill all other PowerShell windows (aggressive approach)
Write-Host "Checking for other PowerShell windows..." -ForegroundColor Yellow
$currentPID = $PID
$otherPS = Get-Process powershell* -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $currentPID }

if ($otherPS) {
    $count = ($otherPS | Measure-Object).Count
    Write-Host "Found $count other PowerShell process(es). Closing..." -ForegroundColor Green
    $otherPS | ForEach-Object {
        $title = if ($_.MainWindowTitle) { $_.MainWindowTitle } else { "(no title)" }
        Write-Host "  Closing PowerShell PID $($_.Id): $title" -ForegroundColor Gray
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    $stoppedAny = $true
} else {
    Write-Host "  No other PowerShell processes found" -ForegroundColor Gray
}

Write-Host ""

# Final cleanup: Kill any remaining Python/Node processes (catches orphaned processes)
Write-Host "Final cleanup: Checking for orphaned Python/Node processes..." -ForegroundColor Yellow
$orphaned = Get-Process python*,node* -ErrorAction SilentlyContinue

if ($orphaned) {
    $count = ($orphaned | Measure-Object).Count
    Write-Host "Found $count orphaned process(es). Stopping..." -ForegroundColor Green
    $orphaned | ForEach-Object {
        Write-Host "  Stopping orphaned $($_.Name) (PID: $($_.Id))" -ForegroundColor Gray
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    $stoppedAny = $true
} else {
    Write-Host "  No orphaned processes found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($stoppedAny) {
    Write-Host "Trader Jarvis servers stopped!" -ForegroundColor Green
} else {
    Write-Host "No Trader Jarvis servers were running" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
