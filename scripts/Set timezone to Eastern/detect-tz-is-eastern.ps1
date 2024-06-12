Write-Host "Starting the detection process for Eastern Standard Time zone..." -ForegroundColor Green

$desiredTimeZone = "Eastern Standard Time"

Write-Host "Retrieving the current time zone..."
$currentTimeZone = (Get-TimeZone).Id

if ($currentTimeZone -eq $desiredTimeZone) {
    Write-Host "Time zone is correctly set to Eastern Standard Time."
    Write-Host "Detection script completed successfully." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Time zone is not set to Eastern Standard Time. Current time zone is $currentTimeZone."
    Write-Host "Detection script detected an issue." -ForegroundColor Red
    exit 1
}
