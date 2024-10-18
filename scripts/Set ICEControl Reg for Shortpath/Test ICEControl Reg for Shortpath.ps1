# Define the registry path and property name
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$propertyName = 'ICEControl'
$expectedValue = 2

# Check if the registry key exists
if (Test-Path -Path $regPath) {
    # Get the property value
    $propertyValue = Get-ItemProperty -Path $regPath -Name $propertyName -ErrorAction SilentlyContinue

    if ($null -ne $propertyValue) {
        # Check if the property value matches the expected value
        if ($propertyValue.$propertyName -eq $expectedValue) {
            Write-Host "The registry key '$regPath' exists and the property '$propertyName' is set to the expected value: $expectedValue." -ForegroundColor Green
            exit 0  # Success
        } else {
            Write-Host "The registry key '$regPath' exists but the property '$propertyName' is not set to the expected value. Current value: $($propertyValue.$propertyName)"
            exit 1  # Property exists but value is incorrect
        }
    } else {
        Write-Host "The registry key '$regPath' exists but the property '$propertyName' does not exist."
        exit 2  # Property does not exist
    }
} else {
    Write-Host "The registry key '$regPath' does not exist."
    exit 3  # Registry key does not exist
}