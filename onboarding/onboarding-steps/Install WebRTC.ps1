$prepPath = "c:\install\avd-prep\"
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