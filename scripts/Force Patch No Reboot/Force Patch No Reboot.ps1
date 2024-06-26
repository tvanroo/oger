# Ensure the Temp directory exists
if (-not (Test-Path -Path 'C:\Temp')) {
    New-Item -ItemType Directory -Path 'C:\Temp'
}

# Generate a unique timestamp for the log file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "C:\Temp\updates$timestamp.txt"

# Redirect output to log file
Start-Transcript -Path $logFilePath

# Install necessary package provider and modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module -Name PSWindowsUpdate

# Install Windows updates
$updateResults = Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Verbose | Out-String

# Stop transcript to end logging
Stop-Transcript

# Determine success or failure
$logContent = Get-Content -Path $logFilePath | Out-String
if ($logContent -match "Found \[0\] Updates in pre search criteria" -or $logContent -match "Installation Results: Success") {
    "SUCCESS" | Out-File -FilePath $logFilePath -Append
} else {
    "FAILURE" | Out-File -FilePath $logFilePath -Append
}

# Return log file path for reference
$logFilePath
