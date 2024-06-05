Write-Host "Starting the process to download and install OneDrive for all users..." -ForegroundColor Green

# Define the OneDrive installer URL and target path
$oneDriveUrl = "https://go.microsoft.com/fwlink/?linkid=844652"
$oneDriveExePath = Join-Path -Path $prepPath -ChildPath "OneDriveSetup.exe"

Write-Host "Downloading the OneDrive installer..."
# Download the OneDrive installer
Invoke-WebRequest -Uri $oneDriveUrl -OutFile $oneDriveExePath

Write-Host "Installing OneDrive for all users..."
# Run the OneDrive installer with /allusers parameter
Start-Process -FilePath $oneDriveExePath -ArgumentList "/allusers" -Wait

Write-Host "Completed the process to download and install OneDrive for all users." -ForegroundColor Green
