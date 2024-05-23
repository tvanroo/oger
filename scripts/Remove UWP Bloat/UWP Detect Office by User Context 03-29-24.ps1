# Setup logging infrastructure
$logDir = "C:\install\logs"
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}
$logFile = Join-Path -Path $logDir -ChildPath ("detect-" + (Get-Date -Format "yyyy-MM-dd-HH-mm-ss") + ".txt")

# Cleanup old logs
Get-ChildItem -Path $logDir -Filter "detect-*.txt" | Where-Object {
    ($_.LastWriteTime -lt (Get-Date).AddHours(-48))
} | Remove-Item

# Start detailed logging
Start-Transcript -Path $logFile
Write-Host "Starting detection script at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"

$appNamePatternsCurrentUser = @(
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

$currentUserPackages = Get-AppxPackage
$foundApps = $false

foreach ($appName in $appNamePatternsCurrentUser) {
    Write-Host "Searching for applications matching pattern: $appName"
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $appName }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $appName."
    } else {
        $foundApps = $true
        foreach ($app in $matchedApps) {
            Write-Host "Found matching app: $($app.Name) PackageFullName: $($app.PackageFullName)"
        }
    }
}

if (-not $foundApps) {
    Write-Host "No matching app(s) for the current user found."
}

Write-Host "Detection script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript
