
# RDP Shortpath registry key
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$regKeyName = "fUseUdpPortRedirector"
$regKeyValue = "1"
$portName = "UdpPortNumber"
$portValue = "3390"

# RDP Shortpath registry key
$regKeyName2 = "ICEControl"
$regKeyValue2 = "2"

Write-Host "Checking if the registry path exists for RDP Shortpath..."
IF(!(Test-Path $WinstationsKey)) {
    New-Item -Path $WinstationsKey -Force | Out-Null
    Write-Host "Created the registry path for RDP Shortpath."
} else {
    Write-Host "Registry path for RDP Shortpath already exists."
}

Write-Host "Setting the registry keys for RDP Shortpath..."
try {
    New-ItemProperty -Path $WinstationsKey -Name $regKeyName -PropertyType DWORD -Value $regKeyValue -Force | Out-Null
    New-ItemProperty -Path $WinstationsKey -Name $regKeyName2 -PropertyType DWORD -Value $regKeyValue2 -Force | Out-Null
    New-ItemProperty -Path $WinstationsKey -Name $portName -PropertyType DWORD -Value $portValue -Force | Out-Null
    Write-Host "Registry keys for RDP Shortpath set successfully."
}
catch {
    Write-Host "Failed to set the registry keys for RDP Shortpath: [$($_.Exception.Message)]"
}
