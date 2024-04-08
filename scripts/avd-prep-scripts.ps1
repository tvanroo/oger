# Version 1.0 from04/01/2024

<# Tasks Executed:
# Major Section: Ensure the AVD preparation directory exists
# Major Section: Deploy VDOT Optimizations 
# Major Section: Download Installer FSLogix - Install run later
# Major Section: Set Timezone to Eastern
# Major Section: Enable AVD Teams Optimization
# Major Section: Install/update WebRTC for AVD
# Major Section: Execute the function to enable Hyper-V
# Major Section: Installing Microsoft 365
# Major Section: Deploy Teams via Bootstrapper
# Major Section: Initiate Task Scheduled Setting (Currently Disabled)
# Major Section: Install WebView2 Runtime
# Major Section: Install/Update FSLogix 

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
    $prepPath = "c:\install\avd-prep\"

    # Define the URL of the ZIP file
    $zipUrl = "https://github.com/tvanroo/oger-vdot/archive/refs/heads/main.zip"
 
    # Define the local path for the downloaded ZIP file using the $prepPath variable
    $zipFilePath = Join-Path -Path $prepPath -ChildPath "downloaded.zip"
 
    # Download the ZIP file
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
 
    # Extract the ZIP file to $prepPath
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $prepPath -Force
 
    # Optionally, remove the ZIP file after extraction if not needed
    Remove-Item -Path $zipFilePath
    
    # Construct the full path to the Windows_VDOT.ps1 script using $prepPath
    $scriptPath = Join-Path -Path $prepPath -ChildPath "oger-vdot-main\Windows_VDOT.ps1"
 
    # Execute the script with arguments
    & $scriptPath -Optimizations AppxPackages, Autologgers, DefaultUserSettings, DiskCleanup, NetworkOptimizations, ScheduledTasks, Services -AdvancedOptimizations Edge, RemoveOneDrive -AcceptEULA
 
# Major Section: Download Installer FSLogix - Install run later
    # -----------------------------------------------------
    # Ensure the AVD preparation directory exists
    $prepPath = "c:\install\avd-prep\"
    if (-not (Test-Path -Path $prepPath)) {
        New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    }

    $fslogixExtractPath = "$prepPath\fslogix"
    if (-not (Test-Path -Path $fslogixExtractPath)) {
        New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
    }

    # Start a background job for downloading and expanding the FSLogix archive
    $job = Start-Job -ScriptBlock {
        param($prepPath, $fslogixExtractPath)
        $fslogixZipPath = "$prepPath\fslogix.zip"
        Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fslogixZipPath
        Expand-Archive -LiteralPath $fslogixZipPath -DestinationPath $fslogixExtractPath -Force
    } -ArgumentList $prepPath, $fslogixExtractPath

# Major Section: Set Timezone to Eastern
    # -----------------------------------------------------
    Set-TimeZone -Id "Eastern Standard Time"

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
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
    $valueName = "IsWVDEnvironment"
    $desiredValue = 1
    
    # Ensure the Teams key exists
    New-Item -Path $registryPath -Force | Out-Null
    
    # Set the desired DWORD value
    New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWORD -Value $desiredValue -Force | Out-Null
    
    Write-Host "IsWVDEnvironment registry setting applied successfully."
    

# Major Section: Install/update WebRTC for AVD
    # -----------------------------------------------------
    $msiPath = Join-Path -Path $prepPath -ChildPath "msrdcwebrtcsvc.msi"
    Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile $msiPath
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait


# Major Section: Execute the function to enable Hyper-V
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart


# Major Section: Installing Microsoft 365
    # -----------------------------------------------------
    $odtFolder = Join-Path -Path $prepPath -ChildPath "ODT"
    if (-not (Test-Path -Path $odtFolder)) {
        New-Item -ItemType Directory -Path $odtFolder | Out-Null
    }

    # Download the ODT setup executable
    $odtExePath = Join-Path -Path $odtFolder -ChildPath "officedeploymenttool_17328-20162.exe"
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe" -OutFile $odtExePath

    # Extract the ODT contents
    Start-Process -FilePath $odtExePath -ArgumentList "/quiet /extract:`"$odtFolder`"" -NoNewWindow -Wait

    # Assuming the ODT contents, including 'setup.exe', are extracted directly into $odtFolder
    $setupPath = Join-Path -Path $odtFolder -ChildPath "setup.exe"

    # Download the XML configuration file
    $xmlFilePath = Join-Path -Path $odtFolder -ChildPath "OGE_Configuration.xml"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/install/OGE_Configuration.xml" -OutFile $xmlFilePath

    # Use the extracted 'setup.exe' for the Office installation/configuration
    Start-Process -FilePath $setupPath -ArgumentList "/configure `"$xmlFilePath`"" -NoNewWindow -Wait


# Major Section: Deploy Teams via Bootstrapper
    # -----------------------------------------------------
 # Define the download URL and target directory
    $url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
    $targetDir = "c:\install\installers"
    $fileName = "teamsbootstrapper.exe"

    # Ensure the target directory exists
    if (-not (Test-Path -Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force
    }

    # Construct the full file path
    $filePath = Join-Path -Path $targetDir -ChildPath $fileName

    # Download the file
    Invoke-WebRequest -Uri $url -OutFile $filePath

    Write-Host "Download completed: $filePath"

    # Execute the downloaded file with the '-p' parameter, suppressing the command prompt window
    Start-Process -FilePath $filePath -ArgumentList "-p" -WindowStyle Hidden -Wait

    Write-Host "Execution completed."
<# Disabled on with the hope that the Old Teams and Office UWP are handled by vdot. 
# Major Section: Initiate Task Scheduled Setting
    # -----------------------------------------------------
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/initiate-task-scheduler.ps1" -OutFile "$env:TEMP\initiate-task-scheduler.ps1"; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:TEMP\initiate-task-scheduler.ps1"
#>

# Major Section: Install WebView2 Runtime
    # -----------------------------------------------------
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"; Start-Process -FilePath "$env:TEMP\MicrosoftEdgeWebview2Setup.exe" -NoNewWindow -Wait

# Major Section: Install/Update FSLogix 
     # -----------------------------------------------------
    # Wait for the background job to complete before starting FSLogix installation
    Wait-Job -Job $job
    Receive-Job -Job $job
    Remove-Job -Job $job
    $fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
    if (Test-Path -Path $fsLogixExePath) {
        Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
        Write-Host "FSLogix has been installed/updated successfully."
    } else {
        Write-Host "FSLogixAppsSetup.exe was not found after extraction."
    }