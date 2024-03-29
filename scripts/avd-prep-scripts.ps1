# Ensure the directory exists
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}

# Define the URL for the timezone script
$timezoneScriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Set%20timezone%20to%20Eastern/remediate-tx-is-eastern.ps1"

# Download and execute the timezone script
$timezoneScriptPath = Join-Path -Path $prepPath -ChildPath "remediate-tx-is-eastern.ps1"
Invoke-WebRequest -Uri $timezoneScriptUrl -OutFile $timezoneScriptPath
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $timezoneScriptPath

# Define the FSLogix extraction path
$fslogixExtractPath = Join-Path -Path $prepPath -ChildPath "fslogix"

# Create the extraction directory if it doesn't exist
if (-not (Test-Path -Path $fslogixExtractPath)) {
    New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
}

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

# Function to download and execute the redistributable installer
function Install-Redistributable {
    param (
        [string]$Architecture
    )
    
    $redistUrl = "https://aka.ms/vs/17/release/vc_redist.$Architecture.exe"
    $redistPath = Join-Path -Path $prepPath -ChildPath "vc_redist.$Architecture.exe"
    
    # Download the redistributable
    Invoke-WebRequest -Uri $redistUrl -OutFile $redistPath
    
    # Start the installer
    Start-Process -FilePath $redistPath -ArgumentList "/quiet", "/norestart" -Wait
}

# Install or update x86 redistributable
Install-Redistributable -Architecture "x86"

# Install or update x64 redistributable
Install-Redistributable -Architecture "x64"