# Define the URL and local path for the MSI
$url = "https://github.com/tvanroo/oger/raw/main/scripts/Deploy%20ActivID%20ActivClient%20x64/ActiveIDClient.msi"
$localPath = "C:\Path\To\Download\Location\ActiveIDClient.msi"

# Download the MSI file
Invoke-WebRequest -Uri $url -OutFile $localPath

# Check if the download was successful
if (Test-Path $localPath) {
    Write-Host "Download successful, installing MSI..."
    # Execute the MSI installer
    Start-Process "msiexec.exe" -ArgumentList "/i `"$localPath`" /qn" -Wait -NoNewWindow
    Write-Host "Installation completed successfully."
} else {
    Write-Host "Download failed, please check the URL and try again."
}
