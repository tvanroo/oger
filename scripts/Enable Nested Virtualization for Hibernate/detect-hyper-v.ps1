Write-Host "Starting the detection process for Microsoft-Hyper-V feature..." -ForegroundColor Green

$featureName = "Microsoft-Hyper-V"

Write-Host "Checking the status of the Microsoft-Hyper-V feature..."
$featureStatus = Get-WindowsOptionalFeature -Online -FeatureName $featureName

if ($featureStatus.State -eq "Enabled") {
    Write-Host "Microsoft-Hyper-V feature is enabled."
    Write-Host "Detection script completed successfully." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Microsoft-Hyper-V feature is not enabled. Current status is $($featureStatus.State)."
    Write-Host "Detection script detected an issue." -ForegroundColor Red
    exit 1
}
