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

$appNamePatternsAllUsers = @(
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

$foundApps = $false

# Detect for current user
$currentUserPackages = Get-AppxPackage
foreach ($appName in $appNamePatternsAllUsers) {
    Write-Host "Searching for applications matching pattern: $appName for current user."
    $matchedApps = $currentUserPackages | Where-Object { $_.Name -like $appName }

    if ($matchedApps.Count -eq 0) {
        Write-Host "No applications found matching pattern: $appName for current user."
    } else {
        $foundApps = $true
        foreach ($app in $matchedApps) {
            Write-Host "Found matching app: $($app.Name) PackageFullName: $($app.PackageFullName) for current user." -ForegroundColor Red
        }
    }
}

# Detect for all users
foreach ($user in Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }) {
    $userSid = $user.SID
    $allUsersPackages = Get-AppxPackage -AllUsers
    foreach ($appName in $appNamePatternsAllUsers) {
        Write-Host "Searching for applications matching pattern: $appName for user with SID: $userSid."
        $matchedApps = $allUsersPackages | Where-Object { $_.Name -like $appName -and $_.InstallLocation -like "*$userSid*" }

        if ($matchedApps.Count -eq 0) {
            Write-Host "No applications found matching pattern: $appName for user with SID: $userSid."
        } else {
            $foundApps = $true
            foreach ($app in $matchedApps) {
                Write-Host "Found matching app: $($app.Name) PackageFullName: $($app.PackageFullName) for user with SID: $userSid." -ForegroundColor Red
            }
        }
    }
}

if (-not $foundApps) {
    Write-Host "No matching app(s) found for any user."
}

Write-Host "Detection script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Stop-Transcript
