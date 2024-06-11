$prepPath = "c:\install\avd-prep\"
Write-Host "Starting the process to uninstall OneDrive for all users..." -ForegroundColor Green

# Define the OneDrive installer URL and target path
$oneDriveUrl = "https://go.microsoft.com/fwlink/?linkid=844652"
$oneDriveExePath = Join-Path -Path $prepPath -ChildPath "OneDriveSetup.exe"

# Ensure the target directory exists
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force
}

Write-Host "Downloading the OneDrive uninstaller..."
# Download the OneDrive installer (it also serves as the uninstaller)
Invoke-WebRequest -Uri $oneDriveUrl -OutFile $oneDriveExePath

Write-Host "Uninstalling OneDrive for all users..."
# Run the OneDrive uninstaller with /allusers and /uninstall parameters
Start-Process -FilePath $oneDriveExePath -ArgumentList "/allusers /uninstall /silent" -Wait

Write-Host "Completed the process to uninstall OneDrive for all users." -ForegroundColor Green
