Write-Host "Starting the process to uninstall Teams ..." -ForegroundColor Green

# Define the uninstall command and target directory
$targetDir = "c:\install\installers"
$fileName = "teamsbootstrapper.exe"
$uninstallCommand = "C:\Program Files (x86)\Teams Installer\Teams.exe"

# Ensure the target directory exists
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

if ($null -eq (Get-AppxPackage -Name MSTeams)) {

	Write-Host "New Teams client not found" -ForegroundColor Blue

} Else {

	Write-Host "Uninstalling Teams..."
    Start-Process -FilePath $uninstallCommand -ArgumentList "--uninstall -s" -Wait
    Write-Host "Teams uninstalled successfully." -ForegroundColor Green
}