$prepPath = "c:\install\avd-prep\"
Write-Host "Starting the process to download and install FSLogix..." -ForegroundColor Green

$fslogixExtractPath = "$prepPath\fslogix"
Write-Host "Checking if the FSLogix extraction path exists..."
if (-not (Test-Path -Path $fslogixExtractPath)) {
    New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
    Write-Host "Created the FSLogix extraction path."
} else {
    Write-Host "FSLogix extraction path already exists."
}

Write-Host "Starting the download and extraction of the FSLogix installer..."
# Download and extract FSLogix
$fslogixZipPath = "$prepPath\fslogix.zip"
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fslogixZipPath
Expand-Archive -LiteralPath $fslogixZipPath -DestinationPath $fslogixExtractPath -Force
Remove-Item -Path $fslogixZipPath

$fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
if (Test-Path -Path $fsLogixExePath) {
    Write-Host "Found FSLogixAppsSetup.exe, starting installation..."
    Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
    Write-Host "FSLogix has been installed/updated successfully."
} else {
    Write-Host "FSLogixAppsSetup.exe was not found after extraction."
}

Write-Host "Completed the process to download and install FSLogix." -ForegroundColor Green