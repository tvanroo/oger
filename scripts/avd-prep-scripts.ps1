<# Tasks Executed:
    Set Timezone to Eastern
    Install/Update FSLogix
    Install Visual C++ Redistributable
    Enable AVD Teams Optimization
    Install/update WebRTC for AVD
    Enable Hyper-V Feature
    Installing Microsoft 365    
    Deploy Teams via Bootstrapper
    Remove UWP Bloat - Office by User Context
    Initiate Task Scheduled Setting
    Install WebView2 Runtime
    
    #>

# Major Section: Ensure the AVD preparation directory exists
    # -----------------------------------------------------
    $prepPath = "c:\install\avd-prep\"
    if (-not (Test-Path -Path $prepPath)) {
        New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    }

# Major Section: Deploy VDOT Optimizations 
    # IMPORTANT: This script references scripts and config files in a different gitHub Repository: https://github.com/tvanroo/oger-vdot 
    # -----------------------------------------------------
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Run%20Cutom%20VDOT/run-custom-vdot%202024-04-01.ps1" -OutFile "$prepPath\run-custom-vdot.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$prepPath\run-custom-vdot.ps1"

# Major Section: Set Timezone to Eastern
    # -----------------------------------------------------
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Set%20timezone%20to%20Eastern/remediate-tx-is-eastern.ps1" -OutFile "$prepPath\remediate-tx-is-eastern.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$prepPath\remediate-tx-is-eastern.ps1"

# Major Section: Download Installer FSLogix - Install run later
    # -----------------------------------------------------
    $fslogixExtractPath = "$prepPath\fslogix"; if (-not (Test-Path -Path $fslogixExtractPath)) { New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null }
    Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile "$prepPath\fslogix.zip"
    Expand-Archive -LiteralPath "$prepPath\fslogix.zip" -DestinationPath $fslogixExtractPath -Force
    
 # Major Section: Install/Update FSLogix 
    $fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
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
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/initiate-task-scheduler.ps1" -OutFile "$env:TEMP\initiate-task-scheduler.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:TEMP\initiate-task-scheduler.ps1"

# Major Section: Install WebView2 Runtime
    # -----------------------------------------------------
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"; Start-Process -FilePath "$env:TEMP\MicrosoftEdgeWebview2Setup.exe" -NoNewWindow -Wait

 # Major Section: Install/Update FSLogix 
 $fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
 if (Test-Path -Path $fsLogixExePath) {
     Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
     Write-Host "FSLogix has been installed/updated successfully."
 } else {
     Write-Host "FSLogixAppsSetup.exe was not found after extraction."
 }