# Setup logging infrastructure
$logDir = "C:\install\logs"
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}
$logFile = Join-Path -Path $logDir -ChildPath ("detect-" + (Get-Date -Format "yyyy-MM-dd-HH-mm-ss") + ".txt")

# Cleanup old logs
Get-ChildItem -Path $logDir -Filter "detect-*.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddHours(-48))
} | Remove-Item

# Start detailed logging
Start-Transcript -Path $logFile
Write-Host "Starting detection script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

$appNamePatternsCurrentUser = @(
    "Microsoft.OutlookForWindows",
    "Microsoft.MicrosoftOfficeHub",
    "microsoft.windowscommunicationsapps"
)

$currentUserPackages = Get-AppxPackage
$foundApps = $false

foreach ($appName in $appNamePatternsCurrentUser) {
    Write-Host "Searching for applications matching pattern: $appName"
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $appName }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $appName."
    } else {
        $foundApps = $true
        foreach ($app in $matchedApps) {
            Write-Host "Found matching app: $($app.Name) PackageFullName: $($app.PackageFullName)"
        }
    }
}

if (-not $foundApps) {
    Write-Host "No matching app(s) for the current user found."
}

Write-Host "Detection script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript
