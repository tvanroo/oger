<# the "MM0DD-YY" at the end of the filename governs if a new version is downloaded and deployed. If saving changes you want implemented, ensure the date is changed to the current date.

This script is grabbed by the silent-launcher.ps1 script set to run at each user login. that launcher won't download a changed version of this file unless the date is changed. Only the latest date will be used. 

#>

# Setup logging infrastructure
$logDir = "C:\install\logs"
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}
$logFile = Join-Path -Path $logDir -ChildPath ("remove-" + (Get-Date -Format "yyyy-MM-dd-HH-mm-ss") + ".txt")

# Cleanup old logs
Get-ChildItem -Path $logDir -Filter "remove-*.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddHours(-48))
} | Remove-Item

# Start detailed logging
Start-Transcript -Path $logFile
Write-Host "Starting removal script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

$appNamePatternsAllUsers = @(
 #   "Clipchamp.Clipchamp",
 #   "Microsoft.549981C3F5F10",
 #   "Microsoft.BingNews",
 #   "Microsoft.Getstarted",
 #   "Microsoft.Office.OneNote",
 #   "Microsoft.PowerAutomateDesktop",
 #   "Microsoft.Windows.DevHome",
 #   "Microsoft.WindowsFeedbackHub",
 #   "Microsoft.YourPhone",
 #   "Microsoft.ZuneMusic",
 #   "Microsoft.ZuneVideo",
 #   "MicrosoftTeams",
 #   "Microsoft.OneDriveSync",
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

# Remove for current user
$currentUserPackages = Get-AppxPackage
foreach ($appName in $appNamePatternsAllUsers) {
    Write-Host "Searching for applications matching pattern: $appName to remove for current user."
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $appName }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $appName for current user."
        continue
    }

    foreach ($app in $matchedApps) {
        $removeCommand = "Remove-AppxPackage -Package $($app.PackageFullName)"
        Write-Host "Attempting to remove: $($app.Name) with command: $removeCommand"
        try {
            Remove-AppxPackage -Package $app.PackageFullName
            Write-Host "Successfully removed: $($app.Name)"
        } catch {
            Write-Host "Failed to remove: $($app.Name). Error: $_"
        }
    }
}

# Remove for all users
foreach ($user in Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }) {
    $userSid = $user.SID
    $allUsersPackages = Get-AppxPackage -AllUsers
    foreach ($appName in $appNamePatternsAllUsers) {
        Write-Host "Searching for applications matching pattern: $appName to remove for user with SID: $userSid."
        $matchedApps = $allUsersPackages | Where-Object { $_.Name -like $appName -and $_.InstallLocation -like "*$userSid*" }

        if ($matchedApps.Count -eq 0) {
            Write-Host "No applications found matching pattern: $appName for user with SID: $userSid."
            continue
        }

        foreach ($app in $matchedApps) {
            $removeCommand = "Remove-AppxPackage -Package $($app.PackageFullName) -User $userSid"
            Write-Host "Attempting to remove: $($app.Name) for user with SID: $userSid with command: $removeCommand"
            try {
                Remove-AppxPackage -Package $app.PackageFullName -User $userSid
                Write-Host "Successfully removed: $($app.Name) for user with SID: $userSid"
            } catch {
                Write-Host "Failed to remove: $($app.Name) for user with SID: $userSid. Error: $_"
            }
        }
    }
}

Write-Host "Removal script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript
