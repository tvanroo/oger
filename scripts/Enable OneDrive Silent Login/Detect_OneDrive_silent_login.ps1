$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'
$DiskSizeregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB'
$TenantGUID = 'c0abca44-0182-40a9-8010-01ec94254f77'
$expectedSilentConfigValue = 1
$expectedDiskSizeValue = 102400

# Function to check if a registry property exists and has the expected value
function Check-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$ExpectedValue
    )

    # Check if the path exists
    if (Test-Path $Path) {
        $currentValue = (Get-ItemProperty -Path $Path).$Name
        if ($currentValue -eq $ExpectedValue) {
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}

# Check SilentAccountConfig
$silentConfigCheck = Check-RegistryValue -Path $HKLMregistryPath -Name 'SilentAccountConfig' -ExpectedValue $expectedSilentConfigValue

# Check DiskSpaceCheckThreshold
$diskSizeCheck = Check-RegistryValue -Path $DiskSizeregistryPath -Name $TenantGUID -ExpectedValue $expectedDiskSizeValue

# Output the results and set exit codes
if ($silentConfigCheck -and $diskSizeCheck) {
    Write-Output "All settings are correctly configured."
    Exit 0  # Success: Settings are correct
} else {
    Write-Output "Settings are not configured correctly."
    Exit 1  # Error: Settings are incorrect
}
