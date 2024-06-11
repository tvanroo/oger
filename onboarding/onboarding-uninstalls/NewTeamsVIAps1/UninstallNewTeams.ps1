Write-Host "Starting the process to uninstall Teams ..." -ForegroundColor Green

# Define the uninstall command and target directory
$targetDir = "c:\install\installers"
$fileName = "teamsbootstrapper.exe"
$uninstallCommand = "C:\Program Files (x86)\Teams Installer\Teams.exe"

# Ensure the target directory exists
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

# Construct the full file path
$filePath = Join-Path -Path $targetDir -ChildPath $fileName

Write-Host "Checking if Teams is installed..."
if (Test-Path -Path $uninstallCommand) {
    Write-Host "Uninstalling Teams..."
    Start-Process -FilePath $uninstallCommand -ArgumentList "--uninstall -s" -Wait
    Write-Host "Teams uninstalled successfully." -ForegroundColor Green
} else {
    Write-Host "Teams is not installed." -ForegroundColor Red
}

Write-Host "Completed the process to uninstall Teams." -ForegroundColor Green
