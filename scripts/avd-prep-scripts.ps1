# Ensure the directory exists
$prepPath = "c:\install\avd-prep\"
if (-not (Test-Path -Path $prepPath)) {
    New-Item -ItemType Directory -Path $prepPath -Force | Out-Null
}

# Define the URL for the timezone script
$timezoneScriptUrl = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/Set%20timezone%20to%20Eastern/remediate-tx-is-eastern.ps1"

# Download the timezone script
$timezoneScriptPath = Join-Path -Path $prepPath -ChildPath "remediate-tx-is-eastern.ps1"
Invoke-WebRequest -Uri $timezoneScriptUrl -OutFile $timezoneScriptPath

# Execute the downloaded timezone script
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $timezoneScriptPath
