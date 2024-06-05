$PackageNames = @(
    "Microsoft.Ink.Handwriting.en-US.1.0",
    "Microsoft.Ink.Handwriting.Main.en-US.1.0.1",
    "Microsoft.GamingApp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.OutlookForWindows",
    "Microsoft.SkypeApp",
    "microsoft.windowscommunicationsapps",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxApp",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Wallet",
    "Microsoft.Windows.Ai.Copilot.Provider"
)

foreach ($PackageName in $PackageNames) {
    Write-Host "`nProcessing package: $PackageName" -ForegroundColor Cyan

    <# Check if the package is installed for all users #>
    Write-Host "`nChecking if $PackageName is installed for all users..." -ForegroundColor Green
    $allUsersPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $PackageName }
    $allUsersFound = $allUsersPackages -ne $null

    <# Check if the package is installed for the current user #>
    Write-Host "`nChecking if $PackageName is installed for the current user..." -ForegroundColor Green
    $currentUserPackage = Get-AppxPackage | Where-Object { $_.Name -eq $PackageName }
    $currentUserFound = $currentUserPackage -ne $null

    <# Report the results #>
    if ($allUsersFound) {
        Write-Host "$PackageName is installed for all users." -ForegroundColor Yellow
    } else {
        Write-Host "$PackageName is not installed for all users." -ForegroundColor Red
    }

    if ($currentUserFound) {
        Write-Host "$PackageName is installed for the current user." -ForegroundColor Yellow
    } else {
        Write-Host "$PackageName is not installed for the current user." -ForegroundColor Red
    }

    <# If the package is found for either all users or the current user, remove the package #>
    if ($allUsersFound -or $currentUserFound) {
        Write-Host "`nRemoving $PackageName for all users and the current user..." -ForegroundColor Green
        
        if ($allUsersFound) {
            $allUsersPackages | ForEach-Object { 
                try {
                    Remove-AppxPackage -Package $_.PackageFullName -AllUsers
                } catch {
                    Write-Host "Error removing package for all users: $_" -ForegroundColor Red
                }
            }
        }
        
        if ($currentUserFound) {
            $currentUserPackage | ForEach-Object { 
                if ($allUsersPackages -notcontains $_) {
                    try {
                        Remove-AppxPackage -Package $_.PackageFullName
                    } catch {
                        Write-Host "Error removing package for the current user: $_" -ForegroundColor Red
                    }
                }
            }
        }

        Write-Host "$PackageName has been removed for all users and the current user." -ForegroundColor Green
    }
}
