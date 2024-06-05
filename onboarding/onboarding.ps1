#################################################################
#Ensure the AVD preparation directory exists
Write-Host "Starting the process to ensure the AVD preparation directory exists..." -ForegroundColor Green

$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    Write-Host "AVD preparation directory does not exist, creating it..."
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    Write-Host "AVD preparation directory created."
} else {
    Write-Host "AVD preparation directory already exists."
}

# Define the log file name with the current timestamp
$timestamp = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$logFilePath = Join-Path -Path $prepPath -ChildPath "avd-prep-script-$timestamp.log"

# Start logging
Start-Transcript -Path $logFilePath -Append
Write-Host "Completed the process to ensure the AVD preparation directory exists." -ForegroundColor Green

#################################################################
#Install Microsoft 365
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Install%20Microsoft%20365.ps1)
#################################################################
#Install Teams
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Install%20Teams.ps1)
#################################################################
#Remove Appx Packages
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Remove%20Appx%20Packages.ps1)
#################################################################
#Enable AF access for FSLogix
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Enable%20AF%20access%20for%20FSLogix.ps1)
#################################################################
#Install FSLogix
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Install%20FSLogix.ps1)
#################################################################
#InstallWebRTC
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Install%20WebRTC.ps1)
#################################################################
#Enable Teams Optimization
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Enable%20Teams%20Optimization.ps1)
#################################################################
#Configure Eastern Timezone
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Configure%20Eastern%20Timezone.ps1)
#################################################################
#Optimize Taskbar
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Optimize%20Taskbar.ps1)
#################################################################
#Enable Hyper-V
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Enable%20Hyper-V.ps1)
#################################################################
#Enforce TLS 1.2+
iex (irm https://github.com/tvanroo/oger/raw/main/onboarding/onboarding-steps/Enforce%20TLS%201.2+.ps1)

#################################################################
Stop-Transcript