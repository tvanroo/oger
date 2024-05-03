
<# the "MM-DD-YY" at the end of the filename governs if a new version is downloaded and deployed. If saving changes you want implemented, ensure the date is changed to the current date.

This script is grabbed by the silent-launcher.ps1 script set to run at each user login. that launcher won't download a changed version of this file unless the date is changed. Only the latest date will be used. 

#>

# Setup logging infrastructure
$logDir = "C:\install\logs"
$username = $env:USERNAME
$flagFileName = "Remove-Old-Teams-LastRun-$username.txt"

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

# Cleanup old logs specific to this script for the current user
Get-ChildItem -Path $logDir -Filter "Remove-Old-Teams-LastRun-$username*.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddDays(-1))
} | Remove-Item

# Attempt to uninstall Teams using Update.exe if Teams is installed
if (Test-Path "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe") {
    & "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe" --uninstall -s
    Start-Sleep -Seconds 5 # Wait a bit to ensure uninstall completes

    # Delete Teams data folders as part of the uninstall process
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
}

# Remove the Start Menu shortcuts for "Microsoft Teams Classic (work or school)", done regardless of uninstallation
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Teams Classic (work or school).lnk" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Teams Classic (work or school).lnk" -Force -ErrorAction SilentlyContinue

# Conclusion of script
Write-Host "Teams removal process completed for user $username."
Stop-Transcript

# Update the LastRun log file's timestamp to indicate successful completion for the current user
"Script last run successfully on $(Get-Date) for user $username" | Out-File -FilePath $flagFile
