<# the "MM-DD-YY" at the end of the filename governs if a new version is downloaded and deployed. If saving changes you want implemented, ensure the date is changed to the current date.

This script is grabbed by the silent-launcher.ps1 script set to run at each user login. that launcherwon't download a changed version of this file unless the date is changed. Only the latest date will be used. 

#>

# Setup logging infrastructure
$logDir = "C:\install\logs"
$username = $env:USERNAME
$flagFileName = "UWP-Remove-Office-LastRun-$username.txt"

if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

$flagFile = Join-Path -Path $logDir -ChildPath $flagFileName

# Check if the script has run in the past 1 days for the current user
if (Test-Path -Path $flagFile) {
    $lastRun = (Get-Item -Path $flagFile).LastWriteTime
    if ((Get-Date) - $lastRun -lt [TimeSpan]::FromDays(1)) {
        Write-Host "Script has already run within the past 1 days for user $username. Exiting."
        exit
    }
}

$logFile = $flagFile
Start-Transcript -Path $logFile

# Cleanup old logs specific to this script
Get-ChildItem -Path $logDir -Filter "UWP-remove-*-$username.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddDays(-1))
} | Remove-Item

# Begin removal process
Write-Host "Starting removal script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
$appNamePatternsCurrentUser = @(
    "Microsoft.OutlookForWindows",
    "Microsoft.MicrosoftOfficeHub",
    "microsoft.windowscommunicationsapps"
)

$currentUserPackages = Get-AppxPackage
$anyRemovalFailed = $false

foreach ($pattern in $appNamePatternsCurrentUser) {
    Write-Host "Searching for applications matching pattern: $pattern to remove."
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $pattern }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $pattern."
    } else {
        foreach ($app in $matchedApps) {
            $removeCommand = "Remove-AppxPackage -Package $($app.PackageFullName)"
            Write-Host "Attempting to remove: $($app.Name) with command: $removeCommand"
            try {
                Remove-AppxPackage -Package $app.PackageFullName
                Write-Host "Successfully removed: $($app.Name)"
            } catch {
                Write-Host "Failed to remove: $($app.Name). Error: $_"
                $anyRemovalFailed = $true
            }
        }
    }
}

# Conclusion and exit code determination
Write-Host "Removal script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript

# Update the LastRun log file's timestamp to indicate successful completion for the current user
"Script last run successfully on $(Get-Date) for user $username" | Out-File -FilePath $flagFile

if ($anyRemovalFailed) {
    exit 1 # Indicates not all apps could be removed successfully, action required
} else {
    exit 0 # Indicates all found apps were successfully removed or none were found, no further action needed
}
