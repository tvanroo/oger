$prepPath = "c:\install\avd-prep\"
$logFile = Join-Path -Path $prepPath -ChildPath "install.log"

# Log function
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

Log-Message "Starting the process to download and install OneDrive for all users..."

# Define the OneDrive installer URL and target path
$oneDriveUrl = "https://go.microsoft.com/fwlink/?linkid=844652"
$oneDriveExePath = Join-Path -Path $prepPath -ChildPath "OneDriveSetup.exe"

Log-Message "Ensuring the target directory exists..."
# Ensure the target directory exists
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    Log-Message "Created the target directory."
} else {
    Log-Message "Target directory already exists."
}

Log-Message "Downloading the OneDrive installer..."
# Download the OneDrive installer
Invoke-WebRequest -Uri $oneDriveUrl -OutFile $oneDriveExePath -ErrorAction Stop

Log-Message "Installing OneDrive for all users..."
# Run the OneDrive installer with /allusers parameter silently
Start-Process -FilePath $oneDriveExePath -ArgumentList "/allusers /silent" -WindowStyle Hidden -Wait

Log-Message "Completed the process to download and install OneDrive for all users."
