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