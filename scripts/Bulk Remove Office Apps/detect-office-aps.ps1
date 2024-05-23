# Define the registry paths where uninstall strings are located
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\*",
    "HKLM:\SOFTWARE\Classes\Installer\Products\*",
    "HKCU:\SOFTWARE\Microsoft\Installer\Products\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Families\*"
)

# Define patterns to match in DisplayName
$displayNamePatterns = @(
    "Microsoft 365 - es-es",
    "Microsoft 365 - fr-fr",
    "Microsoft 365 - pt-br",
    "Aplicaciones de Microsoft 365 para empresas - es-es",
    "Microsoft 365 Apps for enterprise - fr-fr",
    "Microsoft 365 Apps para Grandes Empresas - pt-br"
    "Microsoft OneNote - fr-fr"
    "Microsoft OneNote - es-es"
    "Microsoft OneNote - pt-br"
    "Office 16 Click-to-Run Licensing Component"
    "Office 16 Click-to-Run Extensibility Component"
    "Microsoft OneDrive"
    "Microsoft 365 - en-us"
    "Microsoft OneNote - en-us"
)

# Check for Office in the uninstall paths
$officeProductFound = $false
foreach ($path in $uninstallPaths) {
    $products = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $displayName = $_.DisplayName
        foreach ($pattern in $displayNamePatterns) {
            if ($displayName -like "*$pattern*") {
                $officeProductFound = $true
                break 2 # Exit both loops if a match is found
            }
        }
        $false # Continue searching if no match is found
    }
    if ($officeProductFound) {
        break # Exit if a product has been found
    }
}

# Return exit code based on presence of the office products
if ($officeProductFound) {
    Write-Host "Office product(s) found."
    exit 1 # Indicate success/presence for Intune detection
} else {
    Write-Host "No Office product(s) found."
    exit 0 # Indicate failure/absence for Intune detection
}
