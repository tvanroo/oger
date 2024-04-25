
$registryPath = 'HKLM:\Software\Microsoft\MSRDC\Policies'
$propertyName = 'AutomaticUpdates'
$expectedValue = 0  # Expected value to disable auto updates

# Check if the registry path and property exist and match the expected value
function Check-RegistrySetting {
    param (
        [string]$Path,
        [string]$Name,
        [int]$ExpectedValue
    )
    
    # Check if the registry path exists
    if (Test-Path $Path) {
        # Check if the property exists and has the expected value
        $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
        if ($currentValue -eq $ExpectedValue) {
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}

# Perform the check
$settingIsCorrect = Check-RegistrySetting -Path $registryPath -Name $propertyName -ExpectedValue $expectedValue

# Output the result and set the appropriate exit code
if ($settingIsCorrect) {
    Write-Output "RD Client automatic updates are correctly disabled."
    Exit 0  # Success: The setting is correct
} else {
    Write-Output "RD Client automatic updates are not correctly disabled."
    Exit 1  # Error: The setting is incorrect, remediation needed
}
