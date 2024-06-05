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