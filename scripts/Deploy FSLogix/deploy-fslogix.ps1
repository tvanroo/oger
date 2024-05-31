# Define the preparation path at the beginning of the script
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}

# Define the log file name with the current timestamp
$timestamp = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$logFilePath = Join-Path -Path $prepPath -ChildPath "fslogix-setup-$timestamp.log"

# Start logging
Start-Transcript -Path $logFilePath -Append

#################################################################
#region    Access to Azure File shares for FSLogix profiles     #
#################################################################

Write-Host "Starting the process to configure access to Azure File shares for FSLogix profiles..." -ForegroundColor Green
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Enable Azure AD Kerberos
Write-Host "Enabling Azure AD Kerberos..."
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
$registryKey = "CloudKerberosTicketRetrievalEnabled"
$registryValue = "1"

Write-Host "Checking if the registry path exists for Azure AD Kerberos..."
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created the registry path for Azure AD Kerberos."
} else {
    Write-Host "Registry path for Azure AD Kerberos already exists."
}

Write-Host "Setting the registry key for Azure AD Kerberos..."
try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key for Azure AD Kerberos set successfully."
}
catch {
    Write-Host "Failed to set the registry key for Azure AD Kerberos: [$($_.Exception.Message)]"
}

# Create new reg key "LoadCredKey"
Write-Host "Creating new registry key LoadCredKey..."
$LoadCredRegPath = "HKLM:\Software\Policies\Microsoft\AzureADAccount"
$LoadCredName = "LoadCredKeyFromProfile"
$LoadCredValue = "1"

Write-Host "Checking if the registry path exists for LoadCredKey..."
IF(!(Test-Path $LoadCredRegPath)) {
    New-Item -Path $LoadCredRegPath -Force | Out-Null
    Write-Host "Created the registry path for LoadCredKey."
} else {
    Write-Host "Registry path for LoadCredKey already exists."
}

Write-Host "Setting the registry key for LoadCredKey..."
try {
    New-ItemProperty -Path $LoadCredRegPath -Name $LoadCredName -Value $LoadCredValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key for LoadCredKey set successfully."
}
catch {
    Write-Host "Failed to set the registry key for LoadCredKey: [$($_.Exception.Message)]"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed the process to configure access to Azure File shares for FSLogix profiles." -ForegroundColor Green

#endregion

#################################################################
#region    Download and Install FSLogix                         #
#################################################################

Write-Host "Starting the process to download and install FSLogix..." -ForegroundColor Green

$fslogixExtractPath = "$prepPath\fslogix"
Write-Host "Checking if the FSLogix extraction path exists..."
if (-not (Test-Path -Path $fslogixExtractPath)) {
    New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
    Write-Host "Created the FSLogix extraction path."
} else {
    Write-Host "FSLogix extraction path already exists."
}

Write-Host "Starting the download and extraction of the FSLogix installer..."
# Download and extract FSLogix
$fslogixZipPath = "$prepPath\fslogix.zip"
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fslogixZipPath
Expand-Archive -LiteralPath $fslogixZipPath -DestinationPath $fslogixExtractPath -Force
Remove-Item -Path $fslogixZipPath

$fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
if (Test-Path -Path $fsLogixExePath) {
    Write-Host "Found FSLogixAppsSetup.exe, starting installation..."
    Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
    Write-Host "FSLogix has been installed/updated successfully."
} else {
    Write-Host "FSLogixAppsSetup.exe was not found after extraction."
}

Write-Host "Completed the process to download and install FSLogix." -ForegroundColor Green

#endregion

# End logging
Stop-Transcript
