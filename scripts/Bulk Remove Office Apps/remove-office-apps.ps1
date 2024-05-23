# Define a list of executable names to be terminated
<# $executablesToKill = @(
    "lync", "winword", "excel", "msaccess", "mstore",
    "infopath", "setlang", "msouc", "ois", "onenote",
    "outlook", "powerpnt", "mspub", "groove", "visio",
    "winproj", "graph", "teams"
)

# Iterate through each executable name in the list
foreach ($exe in $executablesToKill) {
    # Get all processes matching the current executable name
    $processes = Get-Process -Name $exe -ErrorAction SilentlyContinue
    
    # Terminate each found process
    foreach ($process in $processes) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Terminated process: $($exe)"
    }
}
#>

# Define the registry paths where uninstall strings are located
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\*"
    "HKLM:\SOFTWARE\Classes\Installer\Products\*"
    "HKCU:\SOFTWARE\Microsoft\Installer\Products\*"
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
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

# Initialize an array to hold the information
$officeProducts = @()

# Search for Office in the uninstall paths and get their details
foreach ($path in $uninstallPaths) {
    $products = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $displayName = $_.DisplayName
        $matchesPattern = $false
        foreach ($pattern in $displayNamePatterns) {
            if ($displayName -like $pattern) {
                $matchesPattern = $true
                break
            }
        }
        $matchesPattern
    }
    foreach ($product in $products) {
        $officeProducts += [PSCustomObject]@{
            "Name"           = $product.DisplayName
            "Version"        = $product.DisplayVersion
            "UninstallString"= $product.UninstallString
        }
    }
}

# Initialize a variable to track the uninstallation status
$uninstallationAttempted = $false

if ($officeProducts.Count -gt 0) {
    Write-Host "Office product(s) found:"
    $officeProducts | Format-Table -AutoSize

    # Indicate that uninstallation will be attempted
    $uninstallationAttempted = $true

    # Iterate over each found product and execute its uninstall command
    foreach ($product in $officeProducts) {
        Write-Host "Uninstalling $($product.Name)..."
        $uninstallString = $product.UninstallString

        # Check if uninstall string is for an MSI product
        if ($uninstallString -match 'MsiExec\.exe /X\{.+?\}') {
            $productCode = $uninstallString -replace '.*MsiExec\.exe /[IX]\{', '' -replace '\}.*', ''
            Start-Process "MsiExec.exe" -ArgumentList "/X{$productCode} /quiet /norestart" -Wait -NoNewWindow
        } elseif ($uninstallString -match 'OfficeClickToRun\.exe') {
            # For OfficeClickToRun, append silent uninstall parameters and execute
            $silentUninstallString = $uninstallString + " displaylevel=false forceappshutdown=true"
            Start-Process "cmd.exe" -ArgumentList "/c `"$silentUninstallString`"" -Wait -NoNewWindow
        } else {
            # For other uninstall strings, execute the command via cmd.exe
            Start-Process "cmd.exe" -ArgumentList "/c `"$uninstallString`"" -Wait -NoNewWindow
        }
    }

    Write-Host "Uninstallation process completed for found products."
} else {
    Write-Host "No Office product(s) found to uninstall."
}

# Determine the final exit status based on whether uninstallation was attempted
if ($uninstallationAttempted) {
    exit 1 # Indicate success/presence for Intune detection
} else {
    exit 0 # Indicate failure/absence for Intune detection
}
