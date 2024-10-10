Set-ExecutionPolicy RemoteSigned -Scope Process -Force

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFilePath = "C:\Temp\updates$timestamp.txt"

# Ensure the C:\Temp directory exists
if (-not (Test-Path -Path 'C:\Temp')) {
    New-Item -ItemType Directory -Path 'C:\Temp' -Force
}

# Install NuGet provider and PSWindowsUpdate module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
Install-Module -Name PSWindowsUpdate -Force -AllowClobber -ErrorAction Stop
Import-Module -Name PSWindowsUpdate -ErrorAction Stop

# Trigger Windows Update and log the output
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot -Verbose *>&1 | Out-File -FilePath $logFilePath