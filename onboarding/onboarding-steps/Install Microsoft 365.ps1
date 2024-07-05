$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install Microsoft 365..." -ForegroundColor Green

$odtFolder = Join-Path -Path $prepPath -ChildPath "ODT"
Write-Host "Checking if the ODT folder exists..."
if (-not (Test-Path -Path $odtFolder)) {
    New-Item -ItemType Directory -Path $odtFolder | Out-Null
    Write-Host "Created the ODT folder."
} else {
    Write-Host "ODT folder already exists."
}

Write-Host "Downloading the Office Deployment Tool executable..."
# Download the ODT setup executable
$odtExePath = Join-Path -Path $odtFolder -ChildPath "officedeploymenttool_17328-20162.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17531-20046.exe" -OutFile $odtExePath

Write-Host "Extracting the Office Deployment Tool contents..."
# Extract the ODT contents
Start-Process -FilePath $odtExePath -ArgumentList "/quiet /extract:`"$odtFolder`"" -Wait

# Assuming the ODT contents, including 'setup.exe', are extracted directly into $odtFolder
$setupPath = Join-Path -Path $odtFolder -ChildPath "setup.exe"

Write-Host "Downloading the XML configuration file..."
# Download the XML configuration file
$xmlFilePath = Join-Path -Path $odtFolder -ChildPath "OGE_Configuration.xml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/install/OGE_Configuration.xml" -OutFile $xmlFilePath

Write-Host "Running the Office setup with the configuration file..."
# Use the extracted 'setup.exe' for the Office installation/configuration
Start-Process -FilePath $setupPath -ArgumentList "/configure `"$xmlFilePath`"" -Wait

Write-Host "Completed the process to install Microsoft 365." -ForegroundColor Green