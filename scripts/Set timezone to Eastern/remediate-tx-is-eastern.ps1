
# Define the path to the TimeZoneInformation registry key
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
# Define the name of the property to update
$propertyName = "TimeZoneKeyName"
# Define the value for Eastern Standard Time
$newTimeZoneValue = "Eastern Standard Time"

try {
    # Update the registry with the new timezone value
    Set-ItemProperty -Path $registryPath -Name $propertyName -Value $newTimeZoneValue

    # Optionally, write output for logging or verification purposes
    Write-Output "Timezone has been successfully updated to Eastern Standard Time."

    # Exit script with success code
    exit 0
} catch {
    # Catch any errors that occur during the update
    Write-Output "Failed to update the timezone. Error: $_"

    # Exit script with error code
    exit 1
}
