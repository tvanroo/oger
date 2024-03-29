# Setup logging infrastructure
$logDir = "C:\install\logs"
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}
$logFile = Join-Path -Path $logDir -ChildPath ("remove-" + (Get-Date -Format "yyyy-MM-dd-HH-mm-ss") + ".txt")

# Cleanup old logs
Get-ChildItem -Path $logDir -Filter "remove-*.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddHours(-48))
} | Remove-Item

# Start detailed logging
Start-Transcript -Path $logFile
Write-Host "Starting removal script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

$appNamePatternsCurrentUser = @(
    "Microsoft.OutlookForWindows",
    "Microsoft.MicrosoftOfficeHub",
    "microsoft.windowscommunicationsapps"
)

$currentUserPackages = Get-AppxPackage
foreach ($appName in $appNamePatternsCurrentUser) {
    Write-Host "Searching for applications matching pattern: $appName to remove."
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $appName }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $appName."
        continue
    }

    foreach ($app in $matchedApps) {
        $removeCommand = "Remove-AppxPackage -Package $($app.PackageFullName)"
        Write-Host "Attempting to remove: $($app.Name) with command: $removeCommand"
        try {
            Remove-AppxPackage -Package $app.PackageFullName
            Write-Host "Successfully removed: $($app.Name)"
        } catch {
            Write-Host "Failed to remove: $($app.Name). Error: $_"
        }
    }
}

Write-Host "Removal script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript
