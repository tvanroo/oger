# Tasks Executed:
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
#    Deploy Teams via Bootstrapper                        # 
#    Install WebView2 Runtime                             #
#    Install/Update FSLogix                               #
#    Taskbar Optimization                                 #
#    Enforce TLS 1.2and higher                            #
#    Stop Windows from installing new Appx automatically  #
#    UWP Remove Appx Bloat Apps                           #


#################################################################
#region    Ensure the AVD preparation directory exists          #
#################################################################
    # -----------------------------------------------------
    $prepPath = "c:\install\avd-prep\"
    if (-not (Test-Path -Path $prepPath)) {
        New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    }
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Disable Storage Sense                                #
#################################################################
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "***Starting AVD AIB CUSTOMIZER PHASE: Disable Storage Sense Start -  $((Get-Date).ToUniversalTime()) "

function Set-RegKey($registryPath, $registryKey, $registryValue) {
    try {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Disable Storage Sense - Setting  $registryKey with value $registryValue ***"
        New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force -ErrorAction Stop
    }
    catch {
        Write-Host "*** AVD AIB CUSTOMIZER PHASE ***   Disable Storage Sense  - Cannot add the registry key  $registryKey *** : [$($_.Exception.Message)]"
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
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Disable Storage Sense - Exit Code: $LASTEXITCODE ***"
Write-Host "*** Ending AVD AIB CUSTOMIZER PHASE: Disable Storage Sense - Time taken: $elapsedTime "


#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Timezone redirection                                 #
#################################################################
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Timezone redirection ***"

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$registryKey = "fEnableTimeZoneRedirection"
$registryValue = "1"

IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Timezone redirection - Cannot add the registry key *** : [$($_.Exception.Message)]"
    Write-Host "Message: [$($_.Exception.Message)"]
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Timezone redirection -  Exit Code: $LASTEXITCODE ***"
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Timezone redirection - Time taken: $elapsedTime ***"

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Access to Azure File shares for FSLogix profiles     #
#################################################################
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "*** Starting AVD AIB CUSTOMIZER PHASE: Access to Azure File shares for FSLogix profiles  ***"

# Enable Azure AD Kerberos

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Enable Azure AD Kerberos ***'
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
$registryKey= "CloudKerberosTicketRetrievalEnabled"
$registryValue = "1"

IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Enable Azure AD Kerberos - Cannot add the registry key $registryKey *** : [$($_.Exception.Message)]"
    Write-Host "Message: [$($_.Exception.Message)"]
}

# Create new reg key "LoadCredKey"
 
Write-Host '*** AVD AIB CUSTOMIZER PHASE *** Create new reg key LoadCredKey ***'

$LoadCredRegPath = "HKLM:\Software\Policies\Microsoft\AzureADAccount"
$LoadCredName = "LoadCredKeyFromProfile"
$LoadCredValue = "1"

IF(!(Test-Path $LoadCredRegPath)) {
     New-Item -Path $LoadCredRegPath -Force | Out-Null
}

try {
    New-ItemProperty -Path $LoadCredRegPath -Name $LoadCredName -Value $LoadCredValue -PropertyType DWORD -Force | Out-Null
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  LoadCredKey - Cannot add the registry key $LoadCredName *** : [$($_.Exception.Message)]"
    Write-Host "Message: [$($_.Exception.Message)"]
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Access to Azure File shares for FSLogix profiles - Exit Code: $LASTEXITCODE ***"
Write-Host "*** Ending AVD AIB CUSTOMIZER PHASE: Access to Azure File shares for FSLogix profiles - Time taken: $elapsedTime "


#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    RDP Shortpath                                        #
#################################################################
# Reference: https://docs.microsoft.com/en-us/azure/virtual-desktop/shortpath

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
write-host 'AVD AIB Customization: Configure RDP shortpath and Windows Defender Firewall'

# rdp shortpath reg key
$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

$regKeyName = "fUseUdpPortRedirector"
$regKeyValue = "1"

$portName = "UdpPortNumber"
$portValue = "3390"


IF(!(Test-Path $WinstationsKey)) {
    New-Item -Path $WinstationsKey -Force | Out-Null
}

try {
    New-ItemProperty -Path $WinstationsKey -Name $regKeyName -ErrorAction:SilentlyContinue -PropertyType:dword -Value $regKeyValue -Force | Out-Null
    New-ItemProperty -Path $WinstationsKey -Name $portName -ErrorAction:SilentlyContinue -PropertyType:dword -Value $portValue -Force | Out-Null
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** RDP Shortpath - Cannot add the registry key *** : [$($_.Exception.Message)]"
    Write-Host "Message: [$($_.Exception.Message)"]
}

# set up windows defender firewall

try {
    New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)'  -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP'  -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol udp -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled:True
}
catch {
    Write-Host "*** AVD AIB CUSTOMIZER PHASE *** Cannot create firewall rule *** : [$($_.Exception.Message)]"
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE : Configure RDP shortpath and Windows Defender Firewall  - Exit Code: $LASTEXITCODE ***"
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Configure RDP shortpath and Windows Defender Firewall - Time taken: $elapsedTime ***"
 
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Disable MSIX auto updates                            #
#################################################################
function Set-RegKey($registryPath, $registryKey, $registryValue) {
    try {
        IF(!(Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force
        }

        Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Disable auto updates for MSIX AA applications - Setting  $registryKey with value $registryValue ***"
        New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force -ErrorAction Stop
    }
    catch {
         Write-Host "*** AVD AIB CUSTOMIZER PHASE ***   Disable Storage Sense  - Cannot add the registry key  $registryKey *** : [$($_.Exception.Message)]"
    }
 }

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "***Starting AVD AIB CUSTOMIZER PHASE: Disable auto updates for MSIX AA applications -  $((Get-Date).ToUniversalTime()) "

Set-RegKey -registryPath "HKLM\Software\Policies\Microsoft\WindowsStore" -registryKey "AutoDownload" -registryValue "2"
Set-RegKey -registryPath "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -registryKey "PreInstalledAppsEnabled" -registryValue "0"
Set-RegKey -registryPath "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug" -registryKey "ContentDeliveryAllowedOverride" -registryValue "0x2"

Disable-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName "Scheduled Start"

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "*** AVD AIB CUSTOMIZER PHASE: Disable auto updates for MSIX AA applications - Exit Code: $LASTEXITCODE ***"
Write-Host "*** Ending AVD AIB CUSTOMIZER PHASE: Disable auto updates for MSIX AA applications - Time taken: $elapsedTime "

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Deploy VDOT Optimizations                            #
#################################################################

    # IMPORTANT: This script references scripts and config files in a different gitHub Repository: https://github.com/tvanroo/oger-vdot 

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
    & $scriptPath -Optimizations AppxPackages, Autologgers, DefaultUserSettings, DiskCleanup, NetworkOptimizations, ScheduledTasks, Services -AdvancedOptimizations Edge -AcceptEULA
#################################################################
#endregion                                                     ##
#################################################################

################################################################# 
#region    Download Installer FSLogix - Install run later       #
#################################################################
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
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Set Timezone to Eastern                              #
#################################################################
    Set-TimeZone -Id "Eastern Standard Time"

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Install Visual C++ Redistributable                   #
#################################################################
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

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Enable AVD Teams Optimization                        #
#################################################################
    # -----------------------------------------------------
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
    $valueName = "IsWVDEnvironment"
    $desiredValue = 1
    
    # Ensure the Teams key exists
    New-Item -Path $registryPath -Force | Out-Null
    
    # Set the desired DWORD value
    New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWORD -Value $desiredValue -Force | Out-Null
    
    Write-Host "IsWVDEnvironment registry setting applied successfully."
    
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Install/update WebRTC for AVD                        #
#################################################################
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
                Write-Host "Attempt $($i): Downloading file from $uri"
                Invoke-WebRequest -Uri $uri -OutFile $outputPath -ErrorAction Stop
                Write-Host "Download successful"
                return $true
            }
            catch {
                Write-Host "Attempt $($i) failed: $($_.Exception.Message)"
                if ($i -lt $retryCount) {
                    Write-Host "Retrying in $retryInterval seconds..."
                    Start-Sleep -Seconds $retryInterval
                }
                else {
                    Write-Host "All attempts failed"
                    return $false
                }
            }
        }
    }
    
    $downloadSuccess = Download-FileWithRetry -uri $uri -outputPath $msiPath -retryCount $retryCount -retryInterval $retryInterval
    
    if ($downloadSuccess) {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
    }
    else {
        Write-Host "Failed to download the MSI file after $retryCount attempts."
    }
    

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Execute the function to enable Hyper-V               #
#################################################################
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Installing Microsoft 365                             #
#################################################################
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

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Deploy Teams via Bootstrapper                       # 
#################################################################
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
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Install WebView2 Runtime                             #
#################################################################
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"; Start-Process -FilePath "$env:TEMP\MicrosoftEdgeWebview2Setup.exe" -NoNewWindow -Wait
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Install/Update FSLogix                               #
#################################################################
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
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Taskbar Optimization                                 #
#################################################################
    $prepPath = "c:\install\avd-prep\"
    if (-not (Test-Path -Path $prepPath)) {
        New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
    }
    
    # Start logging
    Start-Transcript -Path "$prepPath\CustomizeTaskbar_ps1.txt" -Append
    
    [string]$FullRegKeyName = "HKLM:\SOFTWARE\ccmexec\"
    
    # Create registry value if it doesn't exist
    If (!(Test-Path $FullRegKeyName)) {
        New-Item -Path $FullRegKeyName -Type Directory -Force
    }
    New-ItemProperty -Path $FullRegKeyName -Name "CustomizeTaskbar" -Value "1" -PropertyType String -Force
    
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
    
    # Apply settings to the default user profile
    foreach ($value in $values) {
        Set-DefaultUserRegistry -regPath $defaultUserRegPath -name $value.Name -value $value.Value
    }
    
    Write-Host "Settings applied to the default user profile."
    
    # Apply settings to existing user profiles
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
    
    Write-Host "Settings applied to all existing user profiles."
    
    # Stop logging
    Stop-Transcript
 
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Enforce TLS 1.2and higher                            #
#################################################################
    # TLS 1.0 Server and Client Configuration
    $tls10Paths = @(
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server',
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client'
    )
    foreach ($path in $tls10Paths) {
        New-Item $path -Force | Out-Null
        New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType 'DWORD' -Force
        New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWORD' -Force
    }

    # TLS 1.1 Server and Client Configuration
    $tls11Paths = @(
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server',
        'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client'
    )
    foreach ($path in $tls11Paths) {
        New-Item $path -Force | Out-Null
        New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType 'DWORD' -Force
        New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWORD' -Force
    }

    # Update .NET Framework settings to use system defaults and strong crypto
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

    Write-Host "TLS configuration and .NET Framework updates are complete."
#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    Stop Windows from installing new Appx automatically  #
#################################################################
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

    # Apply settings to the default user profile
    foreach ($value in $values) {
        Set-DefaultUserRegistry -regPath $defaultUserRegPath -name $value.Name -value $value.Value
    }

    Write-Host "Settings applied to the default user profile."

    # Apply settings to existing user profiles
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

#################################################################
#endregion                                                     ##
#################################################################

#################################################################
#region    UWP Remove Appx Bloat Apps                           #
#################################################################
iex (irm https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Remove%20UWP%20Bloat/UWP%20Remove%20Appx%20All%20Users%20by%20System%20Context%2005-22-24.ps1)

#################################################################
#endregion                                                     ##
#################################################################

    # Stop logging
    Stop-Transcript