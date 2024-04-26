# Run this script as an Administrator

# Define the feature name
$featureName = "Windows-Defender-ApplicationGuard"

# Check if the feature is enabled
$featureStatus = Get-WindowsOptionalFeature -FeatureName $featureName -Online

# If the feature is enabled, disable it
if ($featureStatus.State -eq "Enabled") {
    Write-Output "Disabling $featureName..."
    Disable-WindowsOptionalFeature -FeatureName $featureName -Online -NoRestart
    Write-Output "$featureName has been disabled."
} else {
    Write-Output "$featureName is not enabled or not found."
}

# Optional: Restart the computer if needed
# Restart-Computer
