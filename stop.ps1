# Trader Jarvis - Stop Script (Name-Based)
# Stops dev servers by identifying processes by script name

Write-Host "Stopping Trader Jarvis..." -ForegroundColor Cyan
Write-Host ""

$stoppedAny = $false
$processesToKill = @()

# Find backend processes (trader-jarvis-backend.py)
Write-Host "Looking for trader-jarvis-backend.py..." -ForegroundColor Yellow
$backendProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -like "*trader-jarvis-backend.py*"
}

if ($backendProcesses) {
    foreach ($proc in $backendProcesses) {
        Write-Host "  Found backend: $($proc.Name) (PID: $($proc.ProcessId))" -ForegroundColor Green

        # Find root parent recursively
        $currentId = $proc.ProcessId
        $rootId = $currentId
        $maxDepth = 10
        $depth = 0

        while ($depth -lt $maxDepth) {
            $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$currentId"
            # Skip root process (terminal running the command)
            if ($parent -and $parent.ParentProcessId -and $parent.ParentProcessId -ne $PID) {
                $parentProc = Get-Process -Id $parent.ParentProcessId -ErrorAction SilentlyContinue
                if ($parentProc -and ($parentProc.Name -like "powershell*" -or $parentProc.Name -like "python*")) {
                    Write-Host "    Found ancestor: $($parentProc.Name) (PID: $($parent.ParentProcessId))" -ForegroundColor DarkGray
                    $rootId = $parent.ParentProcessId
                    $currentId = $parent.ParentProcessId
                    $depth++
                } else {
                    break
                }
            } else {
                break
            }
        }

        $processesToKill += $rootId
    }
}

# Find frontend processes (dev:jarvis or next dev)
Write-Host "Looking for frontend (dev:jarvis)..." -ForegroundColor Yellow
$frontendProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -like "*dev:jarvis*" -or
    ($_.Name -like "node*" -and $_.CommandLine -like "*next*dev*" -and $_.CommandLine -like "*frontend*")
}

if ($frontendProcesses) {
    foreach ($proc in $frontendProcesses) {
        Write-Host "  Found frontend: $($proc.Name) (PID: $($proc.ProcessId))" -ForegroundColor Green

        # Find root parent recursively
        $currentId = $proc.ProcessId
        $rootId = $currentId
        $maxDepth = 10
        $depth = 0

        while ($depth -lt $maxDepth) {
            $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$currentId"
            # Skip root process (terminal running the command)
            if ($parent -and $parent.ParentProcessId -and $parent.ParentProcessId -ne $PID) {
                $parentProc = Get-Process -Id $parent.ParentProcessId -ErrorAction SilentlyContinue
                if ($parentProc -and ($parentProc.Name -like "powershell*" -or $parentProc.Name -like "node*")) {
                    Write-Host "    Found ancestor: $($parentProc.Name) (PID: $($parent.ParentProcessId))" -ForegroundColor DarkGray
                    $rootId = $parent.ParentProcessId
                    $currentId = $parent.ParentProcessId
                    $depth++
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        $processesToKill += $rootId
    }
}

if ($processesToKill.Count -eq 0) {
    Write-Host "  No Trader Jarvis processes found" -ForegroundColor Gray
} else {
    # Remove duplicates
    $processesToKill = $processesToKill | Select-Object -Unique

    Write-Host ""
    Write-Host "Stopping $($processesToKill.Count) root process(es) and their children..." -ForegroundColor Green

    # Recursively get all children
    function Get-AllChildren($ParentId) {
        $children = Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ParentId }
        foreach ($child in $children) {
            $script:allProcessesToKill += $child.ProcessId
            Get-AllChildren $child.ProcessId
        }
    }

    $allProcessesToKill = @()
    foreach ($rootId in $processesToKill) {
        $allProcessesToKill += $rootId
        Get-AllChildren $rootId
    }

    $allProcessesToKill = $allProcessesToKill | Select-Object -Unique

    foreach ($procId in $allProcessesToKill) {
        try {
            $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "  Killing $($proc.Name) (PID: $procId)" -ForegroundColor Gray
                Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
                $stoppedAny = $true
            }
        } catch {
            # Ignore errors
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($stoppedAny) {
    Write-Host "Trader Jarvis stopped!" -ForegroundColor Green
} else {
    Write-Host "No dev servers were running" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
