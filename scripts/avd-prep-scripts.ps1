# Tasks Executed:
#    Ensure the AVD preparation directory exists          #
#    Deploy Teams via Bootstrapper                        # 
#    Disable Storage Sense                                #
#    Timezone redirection                                 #
#    Access to Azure File shares for FSLogix profiles     #
#    RDP Shortpath                                        #
#    Disable MSIX auto updates                            #
#    Deploy VDOT Optimizations                            #
#    Download Installer FSLogix - Install run later       #
#    Set Timezone to Eastern                              #
#    Install Visual C++ Redistributable                   #
#    Enable AVD Teams Optimization                        #
#    Install/update WebRTC for AVD                        #
#    Execute the function to enable Hyper-V               #
#    Installing Microsoft 365                             #
#    Install WebView2 Runtime                             #
#    Install/Update FSLogix                               #
#    Taskbar Optimization                                 #
#    Enforce TLS 1.2and higher                            #
#    Stop Windows from installing new Appx automatically  #
#    UWP Remove Appx Bloat Apps                           #


#################################################################
#region    Ensure the AVD preparation directory exists          #
#################################################################

Write-Host "Starting the process to ensure the AVD preparation directory exists..." -ForegroundColor Green

$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    Write-Host "AVD preparation directory does not exist, creating it..."
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    Write-Host "AVD preparation directory created."
} else {
    Write-Host "AVD preparation directory already exists."
}

# Define the log file name with the current timestamp
$timestamp = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$logFilePath = Join-Path -Path $prepPath -ChildPath "avd-prep-script-$timestamp.log"

# Start logging
Start-Transcript -Path $logFilePath -Append
Write-Host "Completed the process to ensure the AVD preparation directory exists." -ForegroundColor Green

#endregion
                                                
#################################################################
#region    Deploy Teams via Bootstrapper  NEW                   #
#################################################################
#$prepPath = "c:\install\avd-prep\"
<# 
Write-Host "Starting Deploy Teams via Bootstrapper NEW..." -ForegroundColor Green

$scriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Deploy%20Teams%20via%20Bootstrapper/Deploy%20New%20Teams%20Run%20Once.ps1"
$scriptContent = Invoke-RestMethod -Uri $scriptUrl

Write-Host "Saving the script content to a temporary file..."
$tempScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
Set-Content -Path $tempScriptPath -Value $scriptContent

Write-Host "Executing the script with parameters..."
& $tempScriptPath -DownloadExe -ForceInstall -SetRunOnce

Write-Host "Removing the temporary script file..."
Remove-Item -Path $tempScriptPath -Force

Write-Host "Completed Deploy Teams via Bootstrapper NEW." -ForegroundColor Green
#>

#endregion

#################################################################
#region    Disable Storage Sense                                #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting Disable Storage Sense..." -ForegroundColor Green
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "***Starting AVD AIB CUSTOMIZER PHASE: Disable Storage Sense Start - $((Get-Date).ToUniversalTime())"

function Set-RegKey($registryPath, $registryKey, $registryValue) {
    try {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Disable Storage Sense - Setting $registryKey with value $registryValue ***"
        New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force -ErrorAction Stop
    }
    catch {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Disable Storage Sense - Cannot add the registry key $registryKey *** : [$($_.Exception.Message)]"
    }
}

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense"
$registryKey = "AllowStorageSenseGlobal"
$registryValue = "0"

$registryPathWin11 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense"

IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

IF(!(Test-Path $registryPathWin11)) {
    New-Item -Path $registryPathWin11 -Force
}

Set-RegKey -registryPath $registryPath -registryKey $registryKey -registryValue $registryValue
Set-RegKey -registryPath $registryPathWin11 -registryKey $registryKey -registryValue $registryValue

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed

Write-Host "Completed Disable Storage Sense." -ForegroundColor Green
#>

#endregion


#################################################################
#region    Timezone redirection                                 #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to enable Timezone redirection..." -ForegroundColor Green
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$registryKey = "fEnableTimeZoneRedirection"
$registryValue = "1"

Write-Host "Checking if the registry path exists..."
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created the registry path."
} else {
    Write-Host "Registry path already exists."
}

Write-Host "Setting the registry key for Timezone redirection..."
try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key set successfully."
}
catch {
    Write-Host "Failed to set the registry key: [$($_.Exception.Message)]"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed the process to enable Timezone redirection." -ForegroundColor Green

#endregion
#################################################################
#region    Access to Azure File shares for FSLogix profiles     #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to configure access to Azure File shares for FSLogix profiles..." -ForegroundColor Green
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Enable Azure AD Kerberos
Write-Host "Enabling Azure AD Kerberos..."
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
$registryKey = "CloudKerberosTicketRetrievalEnabled"
$registryValue = "1"

Write-Host "Checking if the registry path exists for Azure AD Kerberos..."
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created the registry path for Azure AD Kerberos."
} else {
    Write-Host "Registry path for Azure AD Kerberos already exists."
}

Write-Host "Setting the registry key for Azure AD Kerberos..."
try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key for Azure AD Kerberos set successfully."
}
catch {
    Write-Host "Failed to set the registry key for Azure AD Kerberos: [$($_.Exception.Message)]"
}

# Create new reg key "LoadCredKey"
Write-Host "Creating new registry key LoadCredKey..."
$LoadCredRegPath = "HKLM:\Software\Policies\Microsoft\AzureADAccount"
$LoadCredName = "LoadCredKeyFromProfile"
$LoadCredValue = "1"

Write-Host "Checking if the registry path exists for LoadCredKey..."
IF(!(Test-Path $LoadCredRegPath)) {
    New-Item -Path $LoadCredRegPath -Force | Out-Null
    Write-Host "Created the registry path for LoadCredKey."
} else {
    Write-Host "Registry path for LoadCredKey already exists."
}

Write-Host "Setting the registry key for LoadCredKey..."
try {
    New-ItemProperty -Path $LoadCredRegPath -Name $LoadCredName -Value $LoadCredValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key for LoadCredKey set successfully."
}
catch {
    Write-Host "Failed to set the registry key for LoadCredKey: [$($_.Exception.Message)]"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed the process to configure access to Azure File shares for FSLogix profiles." -ForegroundColor Green

#endregion
#################################################################
#region    RDP Shortpath                                        #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting RDP Shortpath..." -ForegroundColor Green

# Reference: https://docs.microsoft.com/en-us/azure/virtual-desktop/shortpath

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "Configuring RDP Shortpath and Windows Defender Firewall..."

# RDP Shortpath registry key
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$regKeyName = "fUseUdpPortRedirector"
$regKeyValue = "1"
$portName = "UdpPortNumber"
$portValue = "3390"

Write-Host "Checking if the registry path exists for RDP Shortpath..."
IF(!(Test-Path $WinstationsKey)) {
    New-Item -Path $WinstationsKey -Force | Out-Null
    Write-Host "Created the registry path for RDP Shortpath."
} else {
    Write-Host "Registry path for RDP Shortpath already exists."
}

Write-Host "Setting the registry keys for RDP Shortpath..."
try {
    New-ItemProperty -Path $WinstationsKey -Name $regKeyName -PropertyType DWORD -Value $regKeyValue -Force | Out-Null
    New-ItemProperty -Path $WinstationsKey -Name $portName -PropertyType DWORD -Value $portValue -Force | Out-Null
    Write-Host "Registry keys for RDP Shortpath set successfully."
}
catch {
    Write-Host "Failed to set the registry keys for RDP Shortpath: [$($_.Exception.Message)]"
}

# Set up Windows Defender Firewall
Write-Host "Setting up Windows Defender Firewall rule for RDP Shortpath..."
try {
    New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)' -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP' -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol UDP -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled $true
    Write-Host "Firewall rule for RDP Shortpath created successfully."
}
catch {
    Write-Host "Failed to create the firewall rule for RDP Shortpath: [$($_.Exception.Message)]"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed RDP Shortpath." -ForegroundColor Green
#>

#endregion
#################################################################
#region    Disable MSIX auto updates                            #
#################################################################
#$prepPath = "c:\install\avd-prep\"
<#
Write-Host "Starting the process to disable MSIX auto updates..." -ForegroundColor Green

function Set-RegKey($registryPath, $registryKey, $registryValue) {
    try {
        IF(!(Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force
            Write-Host "Created the registry path $registryPath."
        }

        Write-Host "Setting $registryKey with value $registryValue in $registryPath."
        New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force -ErrorAction Stop
        Write-Host "Registry key $registryKey set successfully."
    }
    catch {
        Write-Host "Failed to set the registry key $registryKey in $registryPath: [$($_.Exception.Message)]"
    }
}

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "Disabling auto updates for MSIX AA applications..."

Set-RegKey -registryPath "HKLM\Software\Policies\Microsoft\WindowsStore" -registryKey "AutoDownload" -registryValue "2"
Set-RegKey -registryPath "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -registryKey "PreInstalledAppsEnabled" -registryValue "0"
Set-RegKey -registryPath "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug" -registryKey "ContentDeliveryAllowedOverride" -registryValue "0x2"

Write-Host "Disabling scheduled task for Windows Update..."
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName "Scheduled Start"

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed the process to disable MSIX auto updates." -ForegroundColor Green
#>
#endregion
#################################################################
#region    Deploy VDOT Optimizations                            #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting the process to deploy VDOT optimizations..." -ForegroundColor Green

# IMPORTANT: This script references scripts and config files in a different GitHub Repository: https://github.com/tvanroo/oger-vdot 

# Define the URL of the ZIP file
$zipUrl = "https://github.com/tvanroo/oger-vdot/archive/refs/heads/main.zip"
 
# Define the local path for the downloaded ZIP file using the $prepPath variable
$zipFilePath = Join-Path -Path $prepPath -ChildPath "downloaded.zip"

Write-Host "Downloading the ZIP file from the repository..."
# Download the ZIP file
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
 
Write-Host "Extracting the ZIP file to the preparation path..."
# Extract the ZIP file to $prepPath
Expand-Archive -LiteralPath $zipFilePath -DestinationPath $prepPath -Force
 
Write-Host "Removing the ZIP file after extraction..."
# Optionally, remove the ZIP file after extraction if not needed
Remove-Item -Path $zipFilePath

Write-Host "Constructing the full path to the Windows_VDOT.ps1 script..."
# Construct the full path to the Windows_VDOT.ps1 script using $prepPath
$scriptPath = Join-Path -Path $prepPath -ChildPath "oger-vdot-main\Windows_VDOT.ps1"
 
Write-Host "Executing the VDOT optimization script with arguments..."
# Execute the script with arguments
& $scriptPath -Optimizations  Autologgers, DefaultUserSettings, DiskCleanup, NetworkOptimizations, ScheduledTasks, Services -AdvancedOptimizations Edge -AcceptEULA

Write-Host "Completed the process to deploy VDOT optimizations." -ForegroundColor Green
#>

#endregion

#################################################################
#region    Download Installer FSLogix - Install run later       #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to download the FSLogix installer for later installation..." -ForegroundColor Green

$fslogixExtractPath = "$prepPath\fslogix"
Write-Host "Checking if the FSLogix extraction path exists..."
if (-not (Test-Path -Path $fslogixExtractPath)) {
    New-Item -ItemType Directory -Path $fslogixExtractPath -Force | Out-Null
    Write-Host "Created the FSLogix extraction path."
} else {
    Write-Host "FSLogix extraction path already exists."
}

Write-Host "Starting a background job to download and extract the FSLogix installer..."
# Start a background job for downloading and expanding the FSLogix archive
$job = Start-Job -ScriptBlock {
    param($prepPath, $fslogixExtractPath)
    $fslogixZipPath = "$prepPath\fslogix.zip"
    Write-Host "Downloading the FSLogix installer..."
    Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile $fslogixZipPath
    Write-Host "Extracting the FSLogix installer..."
    Expand-Archive -LiteralPath $fslogixZipPath -DestinationPath $fslogixExtractPath -Force
    Write-Host "FSLogix installer downloaded and extracted successfully."
} -ArgumentList $prepPath, $fslogixExtractPath

Write-Host "Completed the process to download the FSLogix installer for later installation." -ForegroundColor Green

#endregion
#################################################################
#region    Set Timezone to Eastern                              #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to set the timezone to Eastern..." -ForegroundColor Green

Write-Host "Setting the timezone to Eastern Standard Time..."
Set-TimeZone -Id "Eastern Standard Time"

Write-Host "Completed the process to set the timezone to Eastern." -ForegroundColor Green

#endregion
#################################################################
#region    Install Visual C++ Redistributable                   #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install Visual C++ Redistributable..." -ForegroundColor Green

function Install-Redistributable {
    param (
        [string]$Architecture
    )
    $redistUrl = "https://aka.ms/vs/17/release/vc_redist.$Architecture.exe"
    $redistPath = Join-Path -Path $prepPath -ChildPath "vc_redist.$Architecture.exe"

    Write-Host "Downloading Visual C++ Redistributable for $Architecture..."
    Invoke-WebRequest -Uri $redistUrl -OutFile $redistPath

    Write-Host "Installing Visual C++ Redistributable for $Architecture..."
    Start-Process -FilePath $redistPath -ArgumentList "/quiet", "/norestart" -Wait
    Write-Host "Visual C++ Redistributable for $Architecture installed successfully."
}

# Uncomment the following line to install the x86 version
# Install-Redistributable -Architecture "x86"
Install-Redistributable -Architecture "x64"

Write-Host "Completed the process to install Visual C++ Redistributable." -ForegroundColor Green

#endregion
#################################################################
#region    Enable AVD Teams Optimization                        #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to enable AVD Teams Optimization..." -ForegroundColor Green

$registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$desiredValue = 1

Write-Host "Ensuring the Teams registry key exists..."
# Ensure the Teams key exists
New-Item -Path $registryPath -Force | Out-Null
Write-Host "Teams registry key confirmed."

Write-Host "Setting the IsWVDEnvironment registry value..."
# Set the desired DWORD value
New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWORD -Value $desiredValue -Force | Out-Null
Write-Host "IsWVDEnvironment registry value set successfully."

Write-Host "Completed the process to enable AVD Teams Optimization." -ForegroundColor Green

#endregion
#################################################################
#region    Install/update WebRTC for AVD                        #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install/update WebRTC for AVD..." -ForegroundColor Green

$msiPath = Join-Path -Path $prepPath -ChildPath "msrdcwebrtcsvc.msi"
$uri = "https://aka.ms/msrdcwebrtcsvc/msi"
$retryCount = 3
$retryInterval = 5  # seconds

function Download-FileWithRetry {
    param (
        [string]$uri,
        [string]$outputPath,
        [int]$retryCount,
        [int]$retryInterval
    )

    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            Write-Host "Attempt $($i): Downloading file from $uri..."
            Invoke-WebRequest -Uri $uri -OutFile $outputPath -ErrorAction Stop
            Write-Host "Download successful."
            return $true
        }
        catch {
            Write-Host "Attempt $($i) failed: $($_.Exception.Message)"
            if ($i -lt $retryCount) {
                Write-Host "Retrying in $retryInterval seconds..."
                Start-Sleep -Seconds $retryInterval
            }
            else {
                Write-Host "All attempts to download the file have failed."
                return $false
            }
        }
    }
}

Write-Host "Downloading the WebRTC MSI file..."
$downloadSuccess = Download-FileWithRetry -uri $uri -outputPath $msiPath -retryCount $retryCount -retryInterval $retryInterval

if ($downloadSuccess) {
    Write-Host "Installing the WebRTC MSI file..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
    Write-Host "WebRTC installation completed."
} else {
    Write-Host "Failed to download the MSI file after $retryCount attempts."
}

Write-Host "Completed the process to install/update WebRTC for AVD." -ForegroundColor Green

#endregion
#################################################################
#region    Execute the function to enable Hyper-V               #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to enable Hyper-V..." -ForegroundColor Green

Write-Host "Enabling Hyper-V feature..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

Write-Host "Completed the process to enable Hyper-V." -ForegroundColor Green

#endregion
#################################################################
#region    Installing Microsoft 365                             #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install Microsoft 365..." -ForegroundColor Green

$odtFolder = Join-Path -Path $prepPath -ChildPath "ODT"
Write-Host "Checking if the ODT folder exists..."
if (-not (Test-Path -Path $odtFolder)) {
    New-Item -ItemType Directory -Path $odtFolder | Out-Null
    Write-Host "Created the ODT folder."
} else {
    Write-Host "ODT folder already exists."
}

Write-Host "Downloading the Office Deployment Tool executable..."
# Download the ODT setup executable
$odtExePath = Join-Path -Path $odtFolder -ChildPath "officedeploymenttool_17328-20162.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe" -OutFile $odtExePath

Write-Host "Extracting the Office Deployment Tool contents..."
# Extract the ODT contents
Start-Process -FilePath $odtExePath -ArgumentList "/quiet /extract:`"$odtFolder`"" -NoNewWindow -Wait

# Assuming the ODT contents, including 'setup.exe', are extracted directly into $odtFolder
$setupPath = Join-Path -Path $odtFolder -ChildPath "setup.exe"

Write-Host "Downloading the XML configuration file..."
# Download the XML configuration file
$xmlFilePath = Join-Path -Path $odtFolder -ChildPath "OGE_Configuration.xml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/install/OGE_Configuration.xml" -OutFile $xmlFilePath

Write-Host "Running the Office setup with the configuration file..."
# Use the extracted 'setup.exe' for the Office installation/configuration
Start-Process -FilePath $setupPath -ArgumentList "/configure `"$xmlFilePath`"" -NoNewWindow -Wait

Write-Host "Completed the process to install Microsoft 365." -ForegroundColor Green

#endregion
#################################################################
#region    Deploy Teams via Bootstrapper  OLD                   #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting the process to deploy Teams via Bootstrapper (OLD)..." -ForegroundColor Green

# Define the download URL and target directory
$url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
$targetDir = "c:\install\installers"
$fileName = "teamsbootstrapper.exe"

Write-Host "Ensuring the target directory exists..."
# Ensure the target directory exists
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
    Write-Host "Created the target directory."
} else {
    Write-Host "Target directory already exists."
}

# Construct the full file path
$filePath = Join-Path -Path $targetDir -ChildPath $fileName

Write-Host "Downloading the Teams Bootstrapper..."
# Download the file
Invoke-WebRequest -Uri $url -OutFile $filePath
Write-Host "Download completed: $filePath"

Write-Host "Executing the Teams Bootstrapper..."
# Execute the downloaded file with the '-p' parameter, suppressing the command prompt window
Start-Process -FilePath $filePath -ArgumentList "-p" -WindowStyle Hidden -Wait

Write-Host "Completed the process to deploy Teams via Bootstrapper (OLD)." -ForegroundColor Green
#>

#endregion
#################################################################
#region    Install WebView2 Runtime                             #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install WebView2 Runtime..." -ForegroundColor Green

Write-Host "Downloading the WebView2 Runtime installer..."
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"

Write-Host "Installing WebView2 Runtime..."
Start-Process -FilePath "$env:TEMP\MicrosoftEdgeWebview2Setup.exe" -NoNewWindow -Wait

Write-Host "Completed the process to install WebView2 Runtime." -ForegroundColor Green

#endregion
#################################################################
#region    Install/Update FSLogix                               #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install/update FSLogix..." -ForegroundColor Green

Write-Host "Waiting for the background job to complete..."
# Wait for the background job to complete before starting FSLogix installation
Wait-Job -Job $job
Receive-Job -Job $job
Remove-Job -Job $job

$fsLogixExePath = "$fslogixExtractPath\x64\Release\FSLogixAppsSetup.exe"
if (Test-Path -Path $fsLogixExePath) {
    Write-Host "Found FSLogixAppsSetup.exe, starting installation..."
    Start-Process -FilePath $fsLogixExePath -Wait -ArgumentList "/install", "/quiet", "/norestart"
    Write-Host "FSLogix has been installed/updated successfully."
} else {
    Write-Host "FSLogixAppsSetup.exe was not found after extraction."
}

Write-Host "Completed the process to install/update FSLogix." -ForegroundColor Green

#endregion
#################################################################
#region    Taskbar Optimization                                 #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process for Taskbar Optimization..." -ForegroundColor Green

Write-Host "Ensuring the registry key exists..."
[string]$FullRegKeyName = "HKLM:\SOFTWARE\ccmexec\"
# Create registry value if it doesn't exist
If (!(Test-Path $FullRegKeyName)) {
    New-Item -Path $FullRegKeyName -Type Directory -Force
    Write-Host "Created the registry key."
} else {
    Write-Host "Registry key already exists."
}
New-ItemProperty -Path $FullRegKeyName -Name "CustomizeTaskbar" -Value "1" -PropertyType String -Force
Write-Host "Registry key CustomizeTaskbar set."

# Define the registry values to be added for the default user
$values = @(
    @{Name="ShowTaskViewButton"; Value=0}
    @{Name="TaskbarDa"; Value=0}
    @{Name="TaskbarMn"; Value=0}
    @{Name="TaskbarAl"; Value=0}
)

# Base registry path for the default user
$defaultUserRegPath = "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Function to apply the settings using REG ADD
function Set-DefaultUserRegistry {
    param (
        [string]$regPath,
        [string]$name,
        [int]$value
    )
    $cmd = "REG ADD `"$regPath`" /v `"$name`" /t REG_DWORD /d $value /f"
    Write-Host "Executing: $cmd"
    cmd.exe /c $cmd
}

Write-Host "Applying settings to the default user profile..."
# Apply settings to the default user profile
foreach ($value in $values) {
    Set-DefaultUserRegistry -regPath $defaultUserRegPath -name $value.Name -value $value.Value
}
Write-Host "Settings applied to the default user profile."

Write-Host "Applying settings to existing user profiles..."
# Function to apply the settings to a specified registry path
function Set-UserRegistry {
    param (
        [string]$regPath,
        [string]$name,
        [int]$value
    )
    $cmd = "REG ADD `"$regPath`" /v `"$name`" /t REG_DWORD /d $value /f"
    Write-Host "Executing: $cmd"
    cmd.exe /c $cmd
}

# Retrieve all user profiles
$UserProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($UserProfile in $UserProfiles) {
    $sid = $UserProfile.SID
    $profilePath = $UserProfile.LocalPath
    $profileRegPath = "HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    # Load User NTUser.dat if it's not already loaded
    $ProfileWasLoaded = Test-Path "registry::HKEY_USERS\$sid"
    if ($ProfileWasLoaded -eq $false) {
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$sid $profilePath\NTUSER.DAT" -Wait -WindowStyle Hidden
    }

    # Apply settings to the user profile
    foreach ($value in $values) {
        Set-UserRegistry -regPath $profileRegPath -name $value.Name -value $value.Value
    }

    # Unload user's NTUser.dat if it was not previously loaded
    if ($ProfileWasLoaded -eq $false) {
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$sid" -Wait -WindowStyle Hidden
    }
}

Write-Host "Completed Taskbar Optimization." -ForegroundColor Green

#endregion

#################################################################
#region    Enforce TLS 1.2 and higher                           #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to enforce TLS 1.2 and higher..." -ForegroundColor Green

# TLS 1.0 Server and Client Configuration
Write-Host "Configuring TLS 1.0 settings..."
$tls10Paths = @(
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server',
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client'
)
foreach ($path in $tls10Paths) {
    New-Item $path -Force | Out-Null
    New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType 'DWORD' -Force
    New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWORD' -Force
    Write-Host "Configured $path for TLS 1.0."
}

# TLS 1.1 Server and Client Configuration
Write-Host "Configuring TLS 1.1 settings..."
$tls11Paths = @(
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server',
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client'
)
foreach ($path in $tls11Paths) {
    New-Item $path -Force | Out-Null
    New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType 'DWORD' -Force
    New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWORD' -Force
    Write-Host "Configured $path for TLS 1.1."
}

# Update .NET Framework settings to use system defaults and strong crypto
Write-Host "Updating .NET Framework settings to use system defaults and strong crypto..."
$registryPaths = @(
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319",
    "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727",
    "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
)
$registryValues = @{
    "SystemDefaultTlsVersions" = 1
    "SchUseStrongCrypto" = 1
}

foreach ($path in $registryPaths) {
    foreach ($name in $registryValues.Keys) {
        if (Test-Path $path) {
            Set-ItemProperty -Path $path -Name $name -Value $registryValues[$name]
            Write-Host "Updated $name at $path"
        } else {
            Write-Host "Path $path does not exist, skipping..."
        }
    }
}

Write-Host "Completed the process to enforce TLS 1.2 and higher." -ForegroundColor Green

#endregion
#################################################################
#region    Stop Windows from installing new Appx automatically  #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting the process to stop Windows from installing new Appx automatically..." -ForegroundColor Green

# Define the registry values to be added
$values = @(
    @{Name="ContentDeliveryAllowed"; Value=0}
    @{Name="OemPreInstalledAppsEnabled"; Value=0}
    @{Name="PreInstalledAppsEnabled"; Value=0}
    @{Name="PreInstalledAppsEverEnabled"; Value=0}
    @{Name="SilentInstalledAppsEnabled"; Value=0}
    @{Name="SoftLandingEnabled"; Value=0}
    @{Name="SubscribedContent-338388Enabled"; Value=0}
    @{Name="SubscribedContent-338389Enabled"; Value=0}
    @{Name="SubscribedContent-338393Enabled"; Value=0}
    @{Name="SubscribedContent-338394Enabled"; Value=0}
    @{Name="SubscribedContent-338395Enabled"; Value=0}
    @{Name="SubscribedContent-338396Enabled"; Value=0}
    @{Name="SystemPaneSuggestionsEnabled"; Value=0}
)

# Base registry path for the default user
$defaultUserRegPath = "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

# Function to apply the settings using REG ADD for the default user
function Set-DefaultUserRegistry {
    param (
        [string]$regPath,
        [string]$name,
        [int]$value
    )
    $cmd = "REG ADD `"$regPath`" /v `"$name`" /t REG_DWORD /d $value /f"
    Write-Host "Executing: $cmd"
    cmd.exe /c $cmd
}

Write-Host "Applying settings to the default user profile..."
# Apply settings to the default user profile
foreach ($value in $values) {
    Set-DefaultUserRegistry -regPath $defaultUserRegPath -name $value.Name -value $value.Value
}
Write-Host "Settings applied to the default user profile."

Write-Host "Applying settings to existing user profiles..."
# Function to apply the settings to a specified registry path for existing users
function Set-UserRegistry {
    param (
        [string]$regPath,
        [string]$name,
        [int]$value
    )
    $cmd = "REG ADD `"$regPath`" /v `"$name`" /t REG_DWORD /d $value /f"
    Write-Host "Executing: $cmd"
    cmd.exe /c $cmd
}

# Retrieve all user profiles
$UserProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($UserProfile in $UserProfiles) {
    $sid = $UserProfile.SID
    $profilePath = $UserProfile.LocalPath
    $profileRegPath = "HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

    # Load User NTUser.dat if it's not already loaded
    $ProfileWasLoaded = Test-Path "registry::HKEY_USERS\$sid"
    if ($ProfileWasLoaded -eq $false) {
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$sid $profilePath\NTUSER.DAT" -Wait -WindowStyle Hidden
    }

    # Apply settings to the user profile
    foreach ($value in $values) {
        Set-UserRegistry -regPath $profileRegPath -name $value.Name -value $value.Value
    }

    # Unload user's NTUser.dat if it was not previously loaded
    if ($ProfileWasLoaded -eq $false) {
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$sid" -Wait -WindowStyle Hidden
    }
}
Write-Host "Settings applied to all existing user profiles."

Write-Host "Completed the process to stop Windows from installing new Appx automatically." -ForegroundColor Green
#>

#endregion
#################################################################
#region    UWP Remove Appx Bloat Apps                           #
#################################################################
#$prepPath = "c:\install\avd-prep\"

<#
Write-Host "Starting the process to remove UWP Appx Bloat Apps..." -ForegroundColor Green

Write-Host "Executing script to remove UWP bloat apps..."
iex (irm https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Remove%20UWP%20Bloat/UWP%20Remove%20Appx%20All%20Users%20by%20System%20Context%2005-22-24.ps1)

Write-Host "Completed the process to remove UWP Appx Bloat Apps." -ForegroundColor Green
#>

#endregion

# End logging
Stop-Transcript