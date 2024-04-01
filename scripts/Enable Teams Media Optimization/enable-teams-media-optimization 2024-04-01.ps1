# Remediation Script to Set IsWVDEnvironment Registry Value

$registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$desiredValue = 1

# Ensure the Teams key exists
New-Item -Path $registryPath -Force | Out-Null

# Set the desired DWORD value
New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWORD -Value $desiredValue -Force | Out-Null

Write-Host "IsWVDEnvironment registry setting applied successfully."
