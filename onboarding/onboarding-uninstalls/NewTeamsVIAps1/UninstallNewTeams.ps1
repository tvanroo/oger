Write-Host "Starting the process to remove Microsoft Teams Appx package for all users..." -ForegroundColor Green

# Get the package full name of Microsoft Teams
$teamsPackage = Get-AppxPackage -AllUsers -Name "MSTeams"

if ($teamsPackage) {
    # Remove the package for all users
    Remove-AppxPackage -Package $teamsPackage.PackageFullName -AllUsers
    Write-Host "Microsoft Teams Appx package removed for all users." -ForegroundColor Green
} else {
    Write-Host "Microsoft Teams Appx package is not found." -ForegroundColor Red
}

Write-Host "Completed the process to remove Microsoft Teams Appx package for all users." -ForegroundColor Green
