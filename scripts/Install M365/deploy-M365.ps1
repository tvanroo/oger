#iex (irm https://raw.githubusercontent.com/tvanroo/oger/refs/heads/main/scripts/Install%20M365/deploy-M365.ps1)


$prepPath = "c:\install\avd-prep\"

# Major Section: Installing Microsoft 365
# -----------------------------------------------------
$odtFolder = Join-Path -Path $prepPath -ChildPath "ODT"
if (-not (Test-Path -Path $odtFolder)) {
    New-Item -ItemType Directory -Path $odtFolder | Out-Null
}

# Download the ODT setup executable
$odtExePath = Join-Path -Path $odtFolder -ChildPath "officedeploymenttool_17328-20162.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe" -OutFile $odtExePath

# Extract the ODT contents
Start-Process -FilePath $odtExePath -ArgumentList "/quiet /extract:`"$odtFolder`"" -NoNewWindow -Wait

# Assuming the ODT contents, including 'setup.exe', are extracted directly into $odtFolder
$setupPath = Join-Path -Path $odtFolder -ChildPath "setup.exe"

# Download the XML configuration file
$xmlFilePath = Join-Path -Path $odtFolder -ChildPath "OGE_Configuration.xml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/install/OGE_Configuration.xml" -OutFile $xmlFilePath

# Use the extracted 'setup.exe' for the Office installation/configuration
Start-Process -FilePath $setupPath -ArgumentList "/configure `"$xmlFilePath`"" -NoNewWindow -Wait
