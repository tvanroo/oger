# Detection Script for IsWVDEnvironment Registry Setting

$registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$desiredValue = 1

# Check if the path and value exist and are set correctly
if (Test-Path $registryPath) {
    $value = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $valueName
    if ($value -eq $desiredValue) {
        exit 0 # Correct setting found, no remediation needed
    }
}

exit 1 # Setting not found or incorrect, remediation needed
