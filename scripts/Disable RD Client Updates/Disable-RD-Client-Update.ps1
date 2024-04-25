
$registryPath = 'HKLM:\Software\Microsoft\MSRDC\Policies'
$propertyName = 'AutomaticUpdates'
$propertyValue = 0  # 0 to disable auto updates

# Check if the registry path exists, if not, create it
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the property value
if (Test-Path $registryPath) {
    New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType DWORD -Force | Out-Null
} else {
    Write-Output "Failed to create the registry key."
    Exit 1
}

Write-Output "RD Client automatic updates have been disabled."
Exit 0
