Write-Host "Starting the process to enable Hyper-V..." -ForegroundColor Green

Write-Host "Enabling Hyper-V feature..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

Write-Host "Completed the process to enable Hyper-V." -ForegroundColor Green