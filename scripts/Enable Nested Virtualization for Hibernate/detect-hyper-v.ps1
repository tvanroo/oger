# Detection Script for Hyper-V

# Function to check Hyper-V status
function Check-HyperVEnabled {
    $hyperV = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
    if ($hyperV -ne $null -and $hyperV.State -eq "Enabled") {
        return $true
    }
    return $false
}

# Check Hyper-V status and exit accordingly
if (Check-HyperVEnabled) {
    Write-Host "Hyper-V is enabled. Exiting with code 0. No action needed."
    exit 0
} else {
    Write-Host "Hyper-V is not enabled. Exiting with code 1. Remediation required."
    exit 1
}
