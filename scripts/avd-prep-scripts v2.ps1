# Tasks Executed:
#    Ensure the AVD preparation directory exists          #
#    Configure Timezone Settings                          #
#    Install Visual C++ Redistributable                   #
#    Install/update WebRTC for AVD                        #
#    Install WebView2 Runtime                             #
#    Enable AVD Teams Optimization                        #
#    Install Teams in per-machine mode                    #
#    Download and Install OneDrive for All Users          #
#    Taskbar Optimization                                 #
#    Execute the function to enable Hyper-V               #
#    Installing Microsoft 365                             #
#    Enforce TLS 1.2and higher                            #



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
#region    Configure Timezone Settings                          #
#################################################################

Write-Host "Starting the process to configure Timezone settings..." -ForegroundColor Green
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Enable Timezone Redirection
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$registryKey = "fEnableTimeZoneRedirection"
$registryValue = "1"

Write-Host "Checking if the registry path exists for Timezone Redirection..."
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created the registry path for Timezone Redirection."
} else {
    Write-Host "Registry path for Timezone Redirection already exists."
}

Write-Host "Setting the registry key for Timezone Redirection..."
try {
    New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force | Out-Null
    Write-Host "Registry key for Timezone Redirection set successfully."
}
catch {
    Write-Host "Failed to set the registry key for Timezone Redirection: [$($_.Exception.Message)]"
}

# Set Timezone to Eastern
Write-Host "Setting the timezone to Eastern Standard Time..."
Set-TimeZone -Id "Eastern Standard Time"

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
Write-Host "Completed the process to configure Timezone settings." -ForegroundColor Green

#endregion

#################################################################
#region    Install Visual C++ Redistributable                   #
#################################################################

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
Install-Redistributable -Architecture "x86"
Install-Redistributable -Architecture "x64"

Write-Host "Completed the process to install Visual C++ Redistributable." -ForegroundColor Green

#endregion

#################################################################
#region    Install/update WebRTC for AVD                        #
#################################################################

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
#region    Install WebView2 Runtime                             #
#################################################################

Write-Host "Starting the process to install WebView2 Runtime..." -ForegroundColor Green

Write-Host "Downloading the WebView2 Runtime installer..."
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"

Write-Host "Installing WebView2 Runtime..."
Start-Process -FilePath "$env:TEMP\MicrosoftEdgeWebview2Setup.exe" -NoNewWindow -Wait

Write-Host "Completed the process to install WebView2 Runtime." -ForegroundColor Green

#endregion

#################################################################
#region    Enable AVD Teams Optimization                        #
#################################################################

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
#region    Install Teams                   #
#################################################################
#$prepPath = "c:\install\avd-prep\"

Write-Host "Starting the process to install Teams ..." -ForegroundColor Green
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

Write-Host "Downloading the Teams installer..."
Invoke-WebRequest -Uri $url -OutFile $filePath

Write-Host "Download completed: $filePath"

Write-Host "Installing Teams..."
Start-Process -FilePath $filePath -ArgumentList "-p" -WindowStyle Hidden -Wait

Write-Host "Completed the process to install Teams." -ForegroundColor Green

#endregion

#################################################################
#region    Download and Install OneDrive for All Users          #
#################################################################

Write-Host "Starting the process to download and install OneDrive for all users..." -ForegroundColor Green

# Define the OneDrive installer URL and target path
$oneDriveUrl = "https://go.microsoft.com/fwlink/?linkid=844652"
$oneDriveExePath = Join-Path -Path $prepPath -ChildPath "OneDriveSetup.exe"

Write-Host "Downloading the OneDrive installer..."
# Download the OneDrive installer
Invoke-WebRequest -Uri $oneDriveUrl -OutFile $oneDriveExePath

Write-Host "Installing OneDrive for all users..."
# Run the OneDrive installer with /allusers parameter
Start-Process -FilePath $oneDriveExePath -ArgumentList "/allusers" -Wait

Write-Host "Completed the process to download and install OneDrive for all users." -ForegroundColor Green

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
# End logging
Stop-Transcript
