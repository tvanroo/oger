# Start logging to C:\log.txt
Start-Transcript -Path C:\TempLogs\CustomizeTaskbar_ps1.txt -Append

[string]$FullRegKeyName = "HKLM:\SOFTWARE\ccmexec\" 

# Create registry value if it doesn't exist
If (!(Test-Path $FullRegKeyName)) {
    New-Item -Path $FullRegKeyName -type Directory -force 
}
New-itemproperty $FullRegKeyName -Name "CustomizeTaskbar" -Value "1" -Type STRING -Force

# Load default user registry
REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT

# Set registry values for default profile
$defaultPath = "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty $defaultPath -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force
New-ItemProperty $defaultPath -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force
New-ItemProperty $defaultPath -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force
New-ItemProperty $defaultPath -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force

# Unload default user registry
[GC]::Collect()
REG UNLOAD HKLM\Default

# Update registry values for existing users
$UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" |
    Where-Object { $_.PSChildName -match "S-1-5-21-(\d+-?){4}$" } |
    Select-Object @{Name = "SID"; Expression = { $_.PSChildName } }, @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } }

foreach ($UserProfile in $UserProfiles) {
    # Load User NTUser.dat if it's not already loaded
    $ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)
    if ($ProfileWasLoaded -eq $false) {
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE LOAD HKU\$($UserProfile.SID) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden
    }

    # Set registry values for user profile
    $userPath = "registry::HKEY_USERS\$($UserProfile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-ItemProperty $userPath -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword -Force
    New-ItemProperty $userPath -Name "TaskbarDa" -Value "0" -PropertyType Dword -Force
    New-ItemProperty $userPath -Name "TaskbarMn" -Value "0" -PropertyType Dword -Force
    New-ItemProperty $userPath -Name "TaskbarAl" -Value "0" -PropertyType Dword -Force

    # Unload user's NTUser.dat if it was not previously loaded
    if ($ProfileWasLoaded -eq $false) {
        [GC]::Collect()
        Start-Sleep 1
        Start-Process -FilePath "CMD.EXE" -ArgumentList "/C REG.EXE UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden
    }
}

# Stop logging
Stop-Transcript
