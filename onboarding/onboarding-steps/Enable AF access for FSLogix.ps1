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