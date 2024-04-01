# Define the download URL and target directory
$url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
$targetDir = "c:\install\installers"
$fileName = "teamsbootstrapper.exe"

# Ensure the target directory exists
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

# Construct the full file path
$filePath = Join-Path -Path $targetDir -ChildPath $fileName

# Download the file
Invoke-WebRequest -Uri $url -OutFile $filePath

Write-Host "Download completed: $filePath"

# Not installing on this since we'll use Intue App deploy for running this installer. 
# Execute the downloaded file with the '-p' parameter, suppressing the command prompt window
Start-Process -FilePath $filePath -ArgumentList "-p" -WindowStyle Hidden -Wait

Write-Host "Execution completed."
