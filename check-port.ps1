$conn = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn) {
    $pid = $conn.OwningProcess
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "Port 8000 is used by:"
        Write-Host "  PID: $pid"
        Write-Host "  Name: $($proc.Name)"
        Write-Host "  Path: $($proc.Path)"
        Write-Host "  MainWindowTitle: $($proc.MainWindowTitle)"
    } else {
        Write-Host "Port 8000 is used by PID $pid but process details not accessible"
    }
} else {
    Write-Host "Port 8000 is not in use"
}
