# PowerShell Script to Check if GPU Acceleration is Disabled in Microsoft Teams

# Define the path to the Teams configuration file
$TeamsConfigPath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\Microsoft\Teams\desktop-config.json"

# Check if the Teams configuration file exists
if (-not (Test-Path -Path $TeamsConfigPath)) {
    # If the configuration file doesn't exist, exit with 0 (assuming no action needed)
    Write-Host "Teams configuration file not found. Assuming no action needed."
    exit 0
}

# Attempt to read and parse the configuration file
try {
    $TeamsConfig = Get-Content -Path $TeamsConfigPath -ErrorAction Stop | ConvertFrom-Json
    # Check if GPU acceleration setting is present and disabled
    if ($TeamsConfig.appPreferenceSettings.disableGpu -eq $true) {
        Write-Host "GPU acceleration is disabled in Teams."
        exit 0 # Success exit code for Intune detection rule
    } else {
        Write-Host "GPU acceleration is not disabled in Teams."
        exit 1 # Indicates that remediation is needed
    }
}
catch {
    Write-Host "Error reading or parsing Teams configuration file."
    exit 1 # Treat errors in reading or parsing as needing remediation
}
