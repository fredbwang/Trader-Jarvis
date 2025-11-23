$currentPID = $PID
Write-Host "Current PowerShell PID: $currentPID"
Write-Host "Finding other PowerShell processes..."

Get-Process powershell* -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $currentPID } | ForEach-Object {
    Write-Host "Killing PowerShell PID: $($_.Id) - Title: $($_.MainWindowTitle)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Write-Host "Done"
