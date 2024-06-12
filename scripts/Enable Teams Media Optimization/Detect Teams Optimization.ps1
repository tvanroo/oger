Write-Host "Starting the detection process for AVD Teams Optimization..." -ForegroundColor Green

$registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$desiredValue = 1

Write-Host "Checking if the Teams registry key exists..."
# Check if the Teams key exists
if (Test-Path -Path $registryPath) {
    Write-Host "Teams registry key exists."

    Write-Host "Checking the IsWVDEnvironment registry value..."
    # Check if the desired DWORD value is set
    $currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

    if ($currentValue.$valueName -eq $desiredValue) {
        Write-Host "IsWVDEnvironment registry value is set correctly."
        Write-Host "Detection script completed successfully." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "IsWVDEnvironment registry value is not set correctly."
        Write-Host "Detection script detected an issue." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Teams registry key does not exist."
    Write-Host "Detection script detected an issue." -ForegroundColor Red
    exit 1
}
