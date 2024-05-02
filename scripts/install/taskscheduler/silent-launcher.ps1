# Correct URLs for raw content from GitHub
$scriptUrl1 = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/task-scheduler/remove-old-teams-7days%2003-29-24.ps1"
$scriptUrl2 = "https://raw.githubusercontent.com/tvanroo/oger/main/scripts/task-scheduler/remove-uwp-office-7days%2003-29-24.ps1"

# Define local paths for the scripts with dynamic date naming
$dateSuffix = (Get-Date).ToString("MM-dd-yy")
$localPath1 = "C:\install\taskscheduler\remove-old-teams-7days $dateSuffix.ps1"
$localPath2 = "C:\install\taskscheduler\remove-uwp-office-7days $dateSuffix.ps1"

# Ensure the install directory exists
$installDir = "C:\install\taskscheduler"
if (-not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force
}

# Function to download the script if not already present with the latest version
function DownloadScript {
    param(
        [string]$url,
        [string]$path
    )
    if (-not (Test-Path $path)) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $path
            Write-Host "Downloaded script to $path"
        } catch {
            Write-Error "Failed to download script: $_"
        }
    } else {
        Write-Host "Script already exists: $path"
    }
}

# Download the scripts if they do not exist or if a new version is available
DownloadScript -url $scriptUrl1 -path $localPath1
DownloadScript -url $scriptUrl2 -path $localPath2

# Launch the scripts hidden
$scriptBlock1 = { Start-Process "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"C:\install\taskscheduler\remove-old-teams-7days $(Get-Date -Format 'MM-dd-yy').ps1`"" -Wait }
$scriptBlock2 = { Start-Process "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"C:\install\taskscheduler\remove-uwp-office-7days $(Get-Date -Format 'MM-dd-yy').ps1`"" -Wait }

Start-Job -ScriptBlock $scriptBlock1
Start-Job -ScriptBlock $scriptBlock2

# Wait for all jobs to complete
Get-Job | Wait-Job

# Clean up
Get-Job | Remove-Job
