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

# TLS 1.2 and above Server and Client Configuration
Write-Host "Configuring TLS 1.2 and higher settings..."
$tls12Paths = @(
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server',
    'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
)
foreach ($path in $tls12Paths) {
    New-Item $path -Force | Out-Null
    New-ItemProperty -Path $path -Name 'Enabled' -Value 1 -PropertyType 'DWORD' -Force
    New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 0 -PropertyType 'DWORD' -Force
    Write-Host "Configured $path for TLS 1.2."
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
