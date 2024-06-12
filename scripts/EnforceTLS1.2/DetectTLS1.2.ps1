Write-Host "Starting the detection process for enforcing TLS 1.2 and higher..." -ForegroundColor Green

# Function to check registry values
function Test-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$ExpectedValue
    )

    if (Test-Path $Path) {
        $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        if ($currentValue.$Name -eq $ExpectedValue) {
            return $true
        }
    }
    return $false
}

# TLS 1.0 and TLS 1.1 Server and Client Configuration
$tlsPathsAndValues = @{
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' = @{ 'Enabled' = 0; 'DisabledByDefault' = 1 }
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' = @{ 'Enabled' = 0; 'DisabledByDefault' = 1 }
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' = @{ 'Enabled' = 0; 'DisabledByDefault' = 1 }
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' = @{ 'Enabled' = 0; 'DisabledByDefault' = 1 }
}

# Check TLS 1.0 and TLS 1.1 settings
foreach ($path in $tlsPathsAndValues.Keys) {
    foreach ($name in $tlsPathsAndValues[$path].Keys) {
        if (-not (Test-RegistryValue -Path $path -Name $name -ExpectedValue $tlsPathsAndValues[$path][$name])) {
            Write-Host "TLS setting $name at $path is not configured correctly." -ForegroundColor Red
            Write-Host "Detection script detected an issue." -ForegroundColor Red
            exit 1
        }
    }
}

# .NET Framework settings
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

# Check .NET Framework settings
foreach ($path in $registryPaths) {
    foreach ($name in $registryValues.Keys) {
        if (Test-Path $path) {
            if (-not (Test-RegistryValue -Path $path -Name $name -ExpectedValue $registryValues[$name])) {
                Write-Host "$name at $path is not configured correctly." -ForegroundColor Red
                Write-Host "Detection script detected an issue." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Path $path does not exist." -ForegroundColor Yellow
        }
    }
}

Write-Host "All settings for enforcing TLS 1.2 and higher are correctly configured." -ForegroundColor Green
Write-Host "Detection script completed successfully." -ForegroundColor Green
exit 0
