# Ensure the directory exists
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}

# Define the URL for the timezone script
$timezoneScriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Set%20timezone%20to%20Eastern/remediate-tx-is-eastern.ps1"

# Download the timezone script
$timezoneScriptPath = Join-Path -Path $prepPath -ChildPath "remediate-tx-is-eastern.ps1"
Invoke-WebRequest -Uri $timezoneScriptUrl -OutFile $timezoneScriptPath

# Execute the downloaded timezone script
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $timezoneScriptPath

# Download the FSLogix zip file
$fsLogixZipPath = Join-Path -Path $prepPath -ChildPath "fslogix.zip"
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fsLogixZipPath

# Extract the zip file to the specified path
Expand-Archive -LiteralPath $fsLogixZipPath -DestinationPath $fslogixExtractPath -Force

# Find the FSLogixAppsSetup.exe file dynamically
$fsLogixExePath = Get-ChildItem -Path $fslogixExtractPath -Recurse -Filter "FSLogixAppsSetup.exe" | Select-Object -ExpandProperty FullName -First 1

if (-not [string]::IsNullOrEmpty($fsLogixExePath)) {
    # Silently execute the FSLogix installer
    Start-Process -FilePath $fsLogixExePath -ArgumentList "/install", "/quiet", "/norestart" -Wait
    Write-Host "FSLogix has been installed/updated successfully."
} else {
    Write-Host "FSLogixAppsSetup.exe was not found after extraction."
}