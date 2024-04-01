# Ensure the AVD preparation directory exists
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}

# Major Section: Set Timezone to Eastern
# -----------------------------------------------------
$timezoneScriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Set%20timezone%20to%20Eastern/remediate-tx-is-eastern.ps1"
$timezoneScriptPath = Join-Path -Path $prepPath -ChildPath "remediate-tx-is-eastern.ps1"
Invoke-WebRequest -Uri $timezoneScriptUrl -OutFile $timezoneScriptPath
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $timezoneScriptPath

# Major Section: Install/Update FSLogix
# -----------------------------------------------------
$fslogixExtractPath = Join-Path -Path $prepPath -ChildPath "fslogix"
if (-not (Test-Path -Path $fslogixExtractPath)) {
    New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
}
$fsLogixZipPath = Join-Path -Path $prepPath -ChildPath "fslogix.zip"
Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fsLogixZipPath
Expand-Archive -LiteralPath $fsLogixZipPath -DestinationPath $fslogixExtractPath -Force
$fsLogixExePath = Join-Path -Path $fslogixExtractPath -ChildPath "x64\Release\FSLogixAppsSetup.exe"
if (Test-Path -Path $fsLogixExePath) {
    Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
    Write-Host "FSLogix has been installed/updated successfully."
} else {
    Write-Host "FSLogixAppsSetup.exe was not found after extraction."
}

# Major Section: Install Visual C++ Redistributable
# -----------------------------------------------------
function Install-Redistributable {
    param (
        [string]$Architecture
    )
    $redistUrl = "https://aka.ms/vs/17/release/vc_redist.$Architecture.exe"
    $redistPath = Join-Path -Path $prepPath -ChildPath "vc_redist.$Architecture.exe"
    Invoke-WebRequest -Uri $redistUrl -OutFile $redistPath
    Start-Process -FilePath $redistPath -ArgumentList "/quiet", "/norestart" -Wait
}
Install-Redistributable -Architecture "x86"
Install-Redistributable -Architecture "x64"

# Major Section: Enable AVD Teams Optimization
# -----------------------------------------------------
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Enable%20Teams%20Media%20Optimization/enable-teams-media-optimization%202024-04-01.ps1" -OutFile "$prepPath\enable-teams-media-optimization.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$prepPath\enable-teams-media-optimization.ps1"

# Major Section: Install/update WebRTC for AVD
# -----------------------------------------------------
$msiPath = Join-Path -Path $prepPath -ChildPath "msrdcwebrtcsvc.msi"
Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile $msiPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait

# Major Section: Enable Hyper-V Feature
# -----------------------------------------------------
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Enable%20Nested%20Virtualization%20for%20Hibernate/deploy-hyper-v%202024-04-01.ps1" -OutFile "$prepPath\deploy-hyper-v.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$prepPath\deploy-hyper-v.ps1"

# Major Section: Installing Microsoft 365
# -----------------------------------------------------
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Install%20M365/deploy-M365.ps1" -OutFile "$prepPath\deploy-M365.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$prepPath\deploy-M365.ps1"

# Major Section: Deploy Teams via Bootstrapper
# -----------------------------------------------------
$psScriptPath = Join-Path -Path $prepPath -ChildPath "deploy-teams-bootstrapper-exe.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Deploy%20Teams%20via%20Bootstrapper/deploy-teams-bootstrapper-exe%202024-04-01.ps1" -OutFile $psScriptPath
Invoke-Expression -Command (Get-Content -Path $psScriptPath -Raw)

# Major Section: Remove UWP Bloat - Office by User Context
# -----------------------------------------------------
$secondScriptPath = Join-Path -Path $prepPath -ChildPath "UWP_Remove_Office_by_User_Context.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Remove%20UWP%20Bloat/UWP%20Remove%20Office%20by%20User%20Context%20%2003-29-24.ps1" -OutFile $secondScriptPath
Invoke-Expression -Command (Get-Content -Path $secondScriptPath -Raw)

# Major Section: Initiate Task Scheduled Setting
# -----------------------------------------------------
# Define the URL of the PowerShell script
$scriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/initiate-task-scheduler.ps1"

# Specify the local path where the script will be saved
$localScriptPath = Join-Path -Path $env:TEMP -ChildPath "initiate-task-scheduler.ps1"

# Download the script
Invoke-WebRequest -Uri $scriptUrl -OutFile $localScriptPath

# Execute the downloaded script
# Ensure you trust the script source before executing
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $localScriptPath

# Major Section: Install WebView2 Runtime
# -----------------------------------------------------
# Define the URL for the EXE
$exeUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"

# Specify the local path for the downloaded EXE
$localExePath = Join-Path -Path $env:TEMP -ChildPath "MicrosoftEdgeWebview2Setup.exe"

# Attempt to download the EXE file
Invoke-WebRequest -Uri $exeUrl -OutFile $localExePath

# Execute the downloaded EXE file
# NOTE: Adjust the argument list as needed for silent or specific installation options
Start-Process -FilePath $localExePath -NoNewWindow -Wait
