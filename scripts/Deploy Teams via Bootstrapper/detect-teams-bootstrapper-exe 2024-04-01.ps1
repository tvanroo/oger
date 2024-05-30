# Detection script for Microsoft Teams installation via Intune

# Exit codes
$exitCodeInstalled = 0      # Exit code for app installed
$exitCodeNotInstalled = 1   # Exit code for app not installed

try {
    # Check if Microsoft Teams is installed
    if ("MSTeams" -in (Get-ProvisionedAppPackage -Online).DisplayName) {
        Write-Output "Installed"
        exit $exitCodeInstalled
    } else {
        Write-Output "Not Installed"
        exit $exitCodeNotInstalled
    }
} catch {
    Write-Output "Error during detection"
    exit $exitCodeNotInstalled
}
