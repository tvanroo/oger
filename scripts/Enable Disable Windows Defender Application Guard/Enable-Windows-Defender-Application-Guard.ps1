# Run this script as an Administrator

# Define the feature name
$featureName = "Windows-Defender-ApplicationGuard"

# Check if the feature is already enabled
$featureStatus = Get-WindowsOptionalFeature -FeatureName $featureName -Online

# If the feature is not enabled, enable it
if ($featureStatus.State -ne "Enabled") {
    Write-Output "Enabling $featureName..."
    Enable-WindowsOptionalFeature -FeatureName $featureName -Online -NoRestart
    Write-Output "$featureName has been enabled."
} else {
    Write-Output "$featureName is already enabled."
}

# Optional: Restart the computer if needed
# Restart-Computer
