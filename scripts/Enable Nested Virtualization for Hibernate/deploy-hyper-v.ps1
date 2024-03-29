# Simplified Script to Enable Hyper-V on Windows 10 or 11

# PowerShell configurations
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an Administrator." -ForegroundColor Red
    exit
}

# Function to Enable Hyper-V
function Enable-HyperV {
    try {
        # Check if Hyper-V is already enabled
        $hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
        if ($hyperVFeature -ne $null -and $hyperVFeature.State -eq "Enabled") {
            Write-Host "Hyper-V is already enabled."
        }
        else {
            # Enable Hyper-V
            Write-Host "Enabling Hyper-V..."
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell -NoRestart
            Write-Host "Hyper-V has been enabled. Please restart your computer to complete the installation."
        }
    }
    catch {
        Write-Host "An error occurred while enabling Hyper-V: $_" -ForegroundColor Red
        exit -1
    }
}

# Execute the function to enable Hyper-V
Enable-HyperV
