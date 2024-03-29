# Define the path to the registry key
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
# Define the name of the property to check
$propertyName = "TimeZoneKeyName"
# Define the expected timezone value
$expectedTimeZone = "Eastern Standard Time"

# Attempt to retrieve the current timezone from the registry
try {
    $currentTimeZone = Get-ItemProperty -Path $registryPath -Name $propertyName | Select-Object -ExpandProperty $propertyName
} catch {
    Write-Output "Failed to retrieve the timezone from the registry."
    exit 1
}

# Compare the retrieved timezone to the expected value
if ($currentTimeZone -eq $expectedTimeZone) {
    Write-Output "The system timezone is set correctly to '$expectedTimeZone'."
    exit 0
} else {
    Write-Output "The system timezone is set to '$currentTimeZone' but should be '$expectedTimeZone'."
    exit 1
}
