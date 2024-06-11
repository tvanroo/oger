$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to download and install OneDrive for all users..." -ForegroundColor Green

# Define the OneDrive installer URL and target path
$oneDriveUrl = "https://go.microsoft.com/fwlink/?linkid=844652"
$oneDriveExePath = Join-Path -Path $prepPath -ChildPath "OneDriveSetup.exe"

Write-Host "Ensuring the target directory exists..."
# Ensure the target directory exists
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    Write-Host "Created the target directory."
} else {
    Write-Host "Target directory already exists."
}

Write-Host "Downloading the OneDrive installer..."
# Download the OneDrive installer
Invoke-WebRequest -Uri $oneDriveUrl -OutFile $oneDriveExePath -ErrorAction Stop

Write-Host "Installing OneDrive for all users..."
# Run the OneDrive installer with /allusers parameter silently
Start-Process -FilePath $oneDriveExePath -ArgumentList "/allusers" -WindowStyle Hidden -Wait

Write-Host "Completed the process to download and install OneDrive for all users." -ForegroundColor Green
