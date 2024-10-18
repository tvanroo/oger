# Define the registry path, property name, and value
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$propertyName = 'ICEControl'
$propertyValue = 2

# Ensure the registry key exists
if (-not (Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force
}

# Set the registry property value
if (-not (Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $regPath -Name $propertyName -Value $propertyValue -PropertyType DWORD -Force
} else {
    Set-ItemProperty -Path $regPath -Name $propertyName -Value $propertyValue -Force
}

# Verify the registry property value
$setValue = (Get-ItemProperty -Path $regPath -Name $propertyName).$propertyName
if ($setValue -eq $propertyValue) {
    Write-Host "The registry key '$regPath' and property '$propertyName' have been set to the value: $propertyValue."
} else {
    Write-Host "Failed to set the registry key '$regPath' and property '$propertyName' to the value: $propertyValue."
}