# Ensure the directory exists
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}
<# Removed for testing
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

# Specify the path to the FSLogixAppsSetup.exe file
$fsLogixExePath = "C:\install\avd-prep\fslogix\x64\Release\FSLogixAppsSetup.exe"


if (-not [string]::IsNullOrEmpty($fsLogixExePath)) {
    # Silently execute the FSLogix installer
    Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
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


# Enable AVD Teams Optimization
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force

# Install/update WebRTC with the latest version.
$msiPath = "$prepPath\msrdcwebrtcsvc.msi"
Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile $msiPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait

# Enable Hyper-V feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart -Verbose -Confirm:$false
#>

# Define the URL and the local file path
$url = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe"
$odtFolder = Join-Path -Path $prepPath -ChildPath "ODT"
$localFilePath = Join-Path -Path $odtFolder -ChildPath "officedeploymenttool_17328-20162.exe"

# Ensure the ODT folder exists
if (-not (Test-Path -Path $odtFolder)) {
    New-Item -ItemType Directory -Path $odtFolder | Out-Null
}

# Download the file
Invoke-WebRequest -Uri $url -OutFile $localFilePath

# Execute the downloaded file silently
Start-Process -FilePath $localFilePath -ArgumentList "/quiet /extract:$odtFolder" -NoNewWindow -Wait
